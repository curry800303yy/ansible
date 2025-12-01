#!/usr/bin/env python3
"""
MCDN Agent - Zero Dependency Python Implementation
A service that manages nginx configurations and certificates for MCDN domains
"""

import json
import logging
from logging.handlers import TimedRotatingFileHandler
import os
import subprocess
import sys
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import argparse
import time

# Configuration
DEFAULT_CONFIG = {
    "server": {
        "host": "0.0.0.0",
        "port": 8090
    },
    "app": {
        "admin_api_url": "http://markcdn-admin-api:8080",
        "console_api_url": "http://markcdn-console-api:8081"
    },
    "nginx": {
        "path": "/opt/nginx",
        "config_path": "/opt/nginx/conf",
        "cert_path": "/opt/nginx/cert",
        "container_name": "nginx"
    },
    "log": {
        "level": "INFO",
        "file": "/opt/mcdn-agent-py/log/mcdn-agent.log",
        "when": "midnight",
        "backup_count": 14
    },
    "system": {
        "command_timeout": 30
    }
}

# Global config and logger
config = DEFAULT_CONFIG
logger = logging.getLogger("mcdn-agent")


class MCDNAgentHandler(BaseHTTPRequestHandler):
    """HTTP Request Handler for MCDN Agent"""
    
    def log_message(self, format, *args):
        """Override to use our logger"""
        logger.info(f"{self.address_string()} - {format % args}")
    
    def do_GET(self):
        """Handle GET requests"""
        path = urlparse(self.path).path
        
        if path == "/health" or path == "/api/v1/health":
            self._handle_health()
        elif path == "/version":
            self._handle_version()
        else:
            self._send_error(404, "Not Found")
    
    def do_POST(self):
        """Handle POST requests"""
        path = urlparse(self.path).path
        
        if path == "/api/v1/update-config":
            self._handle_update_config()
        else:
            self._send_error(404, "Not Found")
    
    def _read_request_body(self):
        """Read and parse JSON request body"""
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            if content_length == 0:
                return None
            
            body = self.rfile.read(content_length).decode('utf-8')
            return json.loads(body)
        except (ValueError, json.JSONDecodeError) as e:
            logger.error(f"Failed to parse request body: {e}")
            return None
    
    def _send_json_response(self, status_code, data):
        """Send JSON response"""
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        response = json.dumps(data, indent=2)
        self.wfile.write(response.encode('utf-8'))
    
    def _send_error(self, status_code, message):
        """Send error response"""
        self._send_json_response(status_code, {
            "error": message,
            "status": "error"
        })
    
    def _handle_health(self):
        """Handle health check"""
        try:
            agent = MCDNAgent()
            status_data = agent.get_status()
            
            # Determine health based on critical services
            healthy = True
            if not status_data.get("docker", {}).get("available", False):
                healthy = False
            if not status_data.get("templates", {}).get("valid", False):
                healthy = False
            
            response = {
                "status": "healthy" if healthy else "unhealthy",
                "timestamp": int(time.time()),
                "details": status_data
            }
            
            status_code = 200 if healthy else 503
            self._send_json_response(status_code, response)
            
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            self._send_json_response(500, {
                "status": "error",
                "message": f"Health check failed: {str(e)}"
            })
    
    def _handle_version(self):
        """Handle version request"""
        self._send_json_response(200, {
            "service": "mcdn-agent",
            "version": "v1.0.0-python",
            "python_version": sys.version
        })
    
    def _handle_update_config(self):
        """Handle configuration update"""
        # detect dry-run from query string first
        parsed = urlparse(self.path)
        qs = parse_qs(parsed.query)
        def _to_bool(values):
            if not values:
                return False
            v = str(values[0]).lower()
            return v in ("1", "true", "yes", "on")
        dry_run = _to_bool(qs.get("dry-run")) or _to_bool(qs.get("dry_run"))

        data = self._read_request_body()
        if not data:
            self._send_error(400, "Invalid request body")
            return
        
        try:
            agent = MCDNAgent()
            # also support body flag
            if isinstance(data, dict):
                body_dry = data.get("dry_run") or data.get("dry-run")
                if isinstance(body_dry, bool):
                    dry_run = dry_run or body_dry
                elif isinstance(body_dry, str):
                    dry_run = dry_run or body_dry.lower() in ("1", "true", "yes", "on")

            agent.update_configuration(data, dry_run=dry_run)
            self._send_json_response(200, {
                "success": True,
                "message": "Dry run completed successfully" if dry_run else "Configuration updated successfully",
                "dry_run": dry_run
            })
            if dry_run:
                logger.info("Dry-run completed successfully; files written with .dry suffix and no docker actions executed")
            else:
                logger.info("Configuration update completed successfully")
        except ValueError as e:
            self._send_json_response(400, {
                "success": False,
                "message": f"Configuration validation failed: {str(e)}"
            })
        except Exception as e:
            logger.error(f"Configuration update failed: {e}")
            self._send_json_response(500, {
                "success": False,
                "message": f"Configuration update failed: {str(e)}"
            })


class MCDNAgent:
    """Main MCDN Agent service class"""
    
    def __init__(self):
        pass
    
    def _command_timeout(self):
        """Get timeout (seconds) for external commands"""
        try:
            return int(config.get("system", {}).get("command_timeout", 30))
        except (ValueError, TypeError):
            return 30
    
    def validate_configuration(self, data):
        """Validate configuration data.

        - null 值表示删除该模块，允许存在
        - 仅校验值为 dict 的模块
        """
        allowed_domains = ["admin", "console", "api"]
        present_domains = [d for d in allowed_domains if isinstance(data.get(d), dict)]

        # 允许全为空用于纯删除；若至少有一个模块为 dict，则校验该模块
        for domain_type in present_domains:
            domain_config = data[domain_type]

            if not domain_config.get("domain"):
                raise ValueError(f"Missing domain for {domain_type}")

            protocol = domain_config.get("protocol")
            if protocol not in ["http", "https"]:
                raise ValueError(f"Invalid protocol for {domain_type}: {protocol}")

            if protocol == "https":
                if not domain_config.get("cert") or not domain_config.get("key"):
                    raise ValueError(f"Certificate and key required for HTTPS domain: {domain_type}")

                # Validate certificate format and private key
                self._validate_certificate(domain_config["cert"])
                self._validate_private_key(domain_config["key"])
    
    def _validate_certificate(self, cert):
        """Validate certificate PEM format"""
        cert = cert.strip()
        if not cert.startswith("-----BEGIN CERTIFICATE-----"):
            raise ValueError("Certificate must start with '-----BEGIN CERTIFICATE-----'")
        if not cert.endswith("-----END CERTIFICATE-----"):
            raise ValueError("Certificate must end with '-----END CERTIFICATE-----'")
    
    def _validate_private_key(self, key):
        """Validate private key PEM format"""
        key = key.strip()
        valid_headers = [
            "-----BEGIN PRIVATE KEY-----",
            "-----BEGIN RSA PRIVATE KEY-----",
            "-----BEGIN EC PRIVATE KEY-----",
            "-----BEGIN DSA PRIVATE KEY-----"
        ]
        
        valid_footers = [
            "-----END PRIVATE KEY-----",
            "-----END RSA PRIVATE KEY-----",
            "-----END EC PRIVATE KEY-----",
            "-----END DSA PRIVATE KEY-----"
        ]
        
        has_valid_header = any(key.startswith(header) for header in valid_headers)
        has_valid_footer = any(key.endswith(footer) for footer in valid_footers)
        
        if not has_valid_header:
            raise ValueError("Private key must start with a valid PEM header")
        if not has_valid_footer:
            raise ValueError("Private key must end with a valid PEM footer")
    
    def update_configuration(self, data, dry_run=False):
        """Update nginx configuration

        When dry_run is True, write all generated files with a .dry suffix
        and skip any docker validations or commands.
        """
        logger.info("Starting configuration update" + (" (dry-run)" if dry_run else ""))
        
        # Validate configuration
        self.validate_configuration(data)
        
        # Validate templates
        self._validate_templates()
        
        # Validate docker environment only when not dry-run
        if not dry_run:
            self._validate_docker_environment()
        
        # Cleanup previously generated configs that are removed or renamed
        self._cleanup_previous_configs(data, dry_run=dry_run)
        
        # Save certificates
        self._save_certificates(data, dry_run=dry_run)
        
        # Render nginx configs
        self._render_nginx_configs(data, dry_run=dry_run)
        
        # Restart nginx only when not dry-run
        if not dry_run:
            self._restart_nginx()
            logger.info("Configuration update completed")
        else:
            logger.info("Dry-run completed; docker actions skipped")
    
    def _validate_templates(self):
        """Validate templates (now hardcoded in code)"""
        # Templates are now hardcoded, always valid
        logger.debug("Using hardcoded templates, validation skipped")
    
    def _validate_docker_environment(self):
        """Validate docker environment"""
        timeout = self._command_timeout()
        try:
            subprocess.run(["docker", "--version"], check=True, capture_output=True, timeout=timeout)
            
            if not os.path.exists(config["nginx"]["path"]):
                raise FileNotFoundError(f"nginx path does not exist: {config['nginx']['path']}")
            # Verify nginx container exists (best-effort)
            subprocess.run(["docker", "inspect", config["nginx"]["container_name"]], check=True, capture_output=True, timeout=timeout)
                
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Docker environment validation failed: {e}")
        except subprocess.TimeoutExpired as e:
            raise RuntimeError(f"Docker command timed out after {timeout}s: {e.cmd}")
        except FileNotFoundError:
            raise RuntimeError("Docker not found or docker path invalid")
    
    def _save_certificates(self, data, dry_run=False):
        """Save certificates and keys. In dry-run, write with .dry suffix."""
        cert_path = config["nginx"]["cert_path"]
        os.makedirs(cert_path, exist_ok=True)
        
        for domain_type in ["admin", "console", "api"]:
            domain_config = data.get(domain_type)
            if not isinstance(domain_config, dict):
                continue
            if domain_config.get("protocol") == "https":
                domain = domain_config["domain"]
                
                # Save certificate
                cert_file = os.path.join(cert_path, f"{domain}.crt" + (".dry" if dry_run else ""))
                with open(cert_file, 'w') as f:
                    f.write(domain_config["cert"])
                os.chmod(cert_file, 0o644)
                
                # Save private key
                key_file = os.path.join(cert_path, f"{domain}.key" + (".dry" if dry_run else ""))
                with open(key_file, 'w') as f:
                    f.write(domain_config["key"])
                os.chmod(key_file, 0o600)
                
                logger.info(f"Saved certificates for domain: {domain} (dry-run: {dry_run})")
    
    def _render_nginx_configs(self, data, dry_run=False):
        """Render nginx configuration files using hardcoded templates. In dry-run, write with .dry suffix."""
        config_path = config["nginx"]["config_path"]
        os.makedirs(config_path, exist_ok=True)
        
        # Render each provided domain type
        for domain_type in ["admin", "console", "api"]:
            domain_config = data.get(domain_type)
            if not isinstance(domain_config, dict):
                continue
            template_content = self._get_template(domain_type)
            
            # Use Python string formatting
            protocol = domain_config["protocol"]
            is_https = protocol == "https"
            listen_line = "443 ssl" if is_https else "80"
            ssl_block = "" if not is_https else (
                f"  ssl_certificate      /data/identify/{domain_config['domain']}.crt;\n"
                f"  ssl_certificate_key  /data/identify/{domain_config['domain']}.key;\n"
            )

            rendered = template_content.format(
                domain=domain_config["domain"],
                protocol=protocol,
                listen_line=listen_line,
                ssl_block=ssl_block,
                admin_api_url=config["app"]["admin_api_url"],
                console_api_url=config["app"]["console_api_url"]
            )
            
            # Write rendered config
            output_file = os.path.join(config_path, f"{domain_config['domain']}.conf" + (".dry" if dry_run else ""))
            with open(output_file, 'w') as f:
                f.write(rendered)
            
            logger.info(f"Rendered config for {domain_type}: {output_file} (dry-run: {dry_run})")

        # Persist new state (only meaningful outside dry-run)
        self._save_state({
            k: data[k]["domain"] for k in ["admin", "console", "api"] if isinstance(data.get(k), dict) and data[k].get("domain")
        })
            

    # ---------- State management and cleanup ----------
    def _state_file_path(self):
        return os.path.join(config["nginx"]["path"], "mcdn-agent-state.json")

    def _load_state(self):
        path = self._state_file_path()
        try:
            if os.path.exists(path):
                with open(path, 'r') as f:
                    return json.load(f)
        except Exception as e:
            logger.warning(f"Failed to load state file: {e}")
        return {}

    def _save_state(self, domains_map):
        path = self._state_file_path()
        state = {"domains": domains_map}
        try:
            with open(path, 'w') as f:
                json.dump(state, f)
            logger.debug(f"Saved state file: {path}")
        except Exception as e:
            logger.warning(f"Failed to save state file: {e}")

    def _delete_domain_artifacts(self, domain, delete_conf=True, delete_certs=True, dry_run=False):
        config_path = config["nginx"]["config_path"]
        cert_path = config["nginx"]["cert_path"]
        targets = []
        if delete_conf:
            targets.append(os.path.join(config_path, f"{domain}.conf"))
        if delete_certs:
            targets.append(os.path.join(cert_path, f"{domain}.crt"))
            targets.append(os.path.join(cert_path, f"{domain}.key"))

        for p in targets:
            try:
                if dry_run:
                    # In dry-run, actually delete only the .dry variant
                    pdry = p + ".dry"
                    if os.path.exists(pdry):
                        os.remove(pdry)
                        logger.info(f"Deleted (dry): {pdry}")
                    else:
                        logger.debug(f"Skip delete (dry not found): {pdry}")
                else:
                    # Non dry-run: delete the real file
                    if os.path.exists(p):
                        os.remove(p)
                        logger.info(f"Deleted: {p}")
            except Exception as e:
                logger.warning(f"Failed to delete {p if not dry_run else p + '.dry'}: {e}")

    def _cleanup_previous_configs(self, data, dry_run=False):
        """Remove old domain artifacts if a domain is omitted or changed.

        - If a domain type was present previously but omitted now: delete its conf and certs.
        - If a domain changed to a new name: delete old domain's conf and certs.
        - If protocol switched to http for same domain: remove existing certs for that domain.
        """
        prev = self._load_state().get("domains", {})

        for domain_type in ["admin", "console", "api"]:
            prev_domain = prev.get(domain_type)
            new_cfg = data.get(domain_type)

            if not isinstance(new_cfg, dict):
                # Previously existed but now omitted -> delete
                if prev_domain:
                    logger.info(f"Cleaning up removed domain for {domain_type}: {prev_domain}")
                    self._delete_domain_artifacts(prev_domain, delete_conf=True, delete_certs=True, dry_run=dry_run)
                continue

            # Present now
            new_domain = new_cfg.get("domain")
            if prev_domain and new_domain and prev_domain != new_domain:
                # Domain name changed -> delete old
                logger.info(f"Domain changed for {domain_type}: {prev_domain} -> {new_domain}, cleaning old artifacts")
                self._delete_domain_artifacts(prev_domain, delete_conf=True, delete_certs=True, dry_run=dry_run)

            # If protocol downgraded to http -> remove certs for this domain
            if new_cfg.get("protocol") == "http" and new_domain:
                logger.info(f"Protocol http for {domain_type}, ensuring no certs for domain: {new_domain}")
                self._delete_domain_artifacts(new_domain, delete_conf=False, delete_certs=True, dry_run=dry_run)
    
    def _get_template(self, domain_type):
        """Get hardcoded template for domain type"""
        if domain_type == "admin":
            return '''# admin config
server {{
  listen      {listen_line};
  server_name {domain};

  error_log  /var/log/nginx/{domain}-error.log debug;
  access_log /var/log/nginx/{domain}-access.log;

{ssl_block}

  location /basic-api {{
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    proxy_pass {admin_api_url};
    rewrite "^/basic-api/(.*)$" /$1 break;
    proxy_redirect default;
  }}

  location / {{
    proxy_pass http://admin.domain.com;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $host:$server_port;
  }}
}}'''
        
        elif domain_type == "console":
            return '''# console config
server {{
  listen      {listen_line};
  server_name {domain};

  error_log  /var/log/nginx/{domain}-error.log debug;
  access_log /var/log/nginx/{domain}-access.log;

{ssl_block}

  location /basic-api {{
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    
    proxy_pass {console_api_url};
    rewrite "^/basic-api/(.*)$" /$1 break;
    proxy_redirect default;
  }}

  location /public/ {{
    proxy_pass http://admin.api;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $host:$server_port;
  }}
  
  location / {{
    proxy_pass http://console.domain.com;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $host:$server_port;
  }}
}}'''
        
        elif domain_type == "api":
            return '''# api config
server {{
  listen      {listen_line};
  server_name {domain};

  error_log  /var/log/nginx/{domain}-error.log debug;
  access_log /var/log/nginx/{domain}-access.log;

{ssl_block}

  # 默认版本号、子系统、请求路径
  set $version v1;
  set $subsystem console;
  set $subsystem_request_uri $request_uri;

  # /子系统/path...
  if ($request_uri ~* "^/([a-z]\\w+[a-z0-9]+)/(.*)") {{
    set $subsystem $1;
    set $subsystem_request_uri $2;
  }}

  # /子系统/版本号/path...
  if ($request_uri ~* "^/([a-z]\\w+[a-z0-9]+)/(v[0-9]{{1,3}})/(.*)") {{
    set $subsystem $1;
    set $version $2;
    set $subsystem_request_uri $3;
  }}

  # 如果所有的子系统都不匹配，设置成默认的子系统
  if ($subsystem !~* "^(console|admin)$") {{
    set $subsystem console;
  }}

  location  / {{
    proxy_pass http://$subsystem.api/$subsystem_request_uri;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Version $version;
    proxy_set_header Host $host:$server_port;
  }}
}}'''
        
        else:
            raise ValueError(f"Unknown domain type: {domain_type}")
    
    def _restart_nginx(self):
        """Reload nginx via docker exec"""
        logger.info("Reloading nginx via docker exec")
        timeout = self._command_timeout()
        try:
            subprocess.run(
                ["docker", "exec", "-i", config["nginx"]["container_name"], "nginx", "-s", "reload"],
                check=True,
                capture_output=True,
                text=True,
                timeout=timeout,
            )
            logger.info("Successfully reloaded nginx via docker exec")
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to reload nginx: {e}")
        except subprocess.TimeoutExpired as e:
            raise RuntimeError(f"Nginx reload timed out after {timeout}s: {e.cmd}")
    
    def get_status(self):
        """Get service status"""
        status = {}
        
        # Check nginx status
        try:
            nginx_running = self._check_nginx_status()
            status["nginx"] = {"running": nginx_running}
        except Exception as e:
            status["nginx"] = {"running": False, "error": str(e)}
        
        # Check paths
        status["paths"] = {
            "configPath": config["nginx"]["config_path"],
            "certPath": config["nginx"]["cert_path"],
            "nginxPath": config["nginx"]["path"]
        }
        
        # Check templates
        try:
            self._validate_templates()
            status["templates"] = {"valid": True}
        except Exception as e:
            status["templates"] = {"valid": False, "error": str(e)}
        
        # Check docker environment
        try:
            self._validate_docker_environment()
            status["docker"] = {"available": True}
        except Exception as e:
            status["docker"] = {"available": False, "error": str(e)}
        
        return status
    
    def _check_nginx_status(self):
        """Check if nginx container is running"""
        timeout = self._command_timeout()
        try:
            # Check container state via docker inspect
            result = subprocess.run(
                ["docker", "inspect", "-f", "{{.State.Running}}", config["nginx"]["container_name"]],
                check=True,
                capture_output=True,
                text=True,
                timeout=timeout,
            )
            running = result.stdout.strip().lower() == "true"
            if running:
                return True
            # Fallback: docker ps text parse
            ps = subprocess.run(["docker", "ps"], check=True, capture_output=True, text=True, timeout=timeout)
            for line in ps.stdout.splitlines():
                if config["nginx"]["container_name"] in line and "Up" in line:
                    return True
            return False
        except subprocess.CalledProcessError:
            return False
        except subprocess.TimeoutExpired:
            return False


def setup_logging(log_level=None):
    """Setup logging configuration with daily rotation to file and console output."""
    # Resolve level
    level_name = (log_level or config["log"].get("level", "INFO")).upper()
    level = getattr(logging, level_name, logging.INFO)

    # Prepare handlers
    handlers = []

    # Console
    console_handler = logging.StreamHandler()
    handlers.append(console_handler)

    # File with daily rotation
    log_file = config["log"].get("file")
    if log_file:
        try:
            os.makedirs(os.path.dirname(log_file), exist_ok=True)
            when = config["log"].get("when", "midnight")
            backup_count = int(config["log"].get("backup_count", 14))
            file_handler = TimedRotatingFileHandler(log_file, when=when, backupCount=backup_count, encoding="utf-8")
            handlers.append(file_handler)
        except Exception as e:
            # Fall back to console only
            print(f"Failed to setup file logging: {e}")

    fmt = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    for h in handlers:
        h.setFormatter(fmt)

    root_logger = logging.getLogger()
    root_logger.handlers = []
    root_logger.setLevel(level)
    for h in handlers:
        root_logger.addHandler(h)


def load_config(config_file=None):
    """Load configuration from JSON file or use defaults"""
    global config
    
    if config_file and os.path.exists(config_file):
        try:
            with open(config_file, 'r') as f:
                file_config = json.load(f)
            
            # Merge with default config
            def merge_dict(default, override):
                for key, value in override.items():
                    if key in default and isinstance(default[key], dict) and isinstance(value, dict):
                        merge_dict(default[key], value)
                    else:
                        default[key] = value
            
            merge_dict(config, file_config)
            logger.info(f"Loaded configuration from {config_file}")
        except Exception as e:
            logger.warning(f"Failed to load config file {config_file}: {e}, using defaults")


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="MCDN Agent - Python Implementation")
    parser.add_argument("--config", "-c", help="Configuration file path (JSON format)", default="config.json")
    parser.add_argument("--host", help="Server host")
    parser.add_argument("--port", type=int, help="Server port")
    parser.add_argument("--log-level", choices=["DEBUG", "INFO", "WARNING", "ERROR"], help="Log level")
    
    args = parser.parse_args()
    
    # Load configuration
    load_config(args.config)
    
    # Setup logging (after config is loaded so file path is available)
    log_level = args.log_level or config["log"].get("level", "INFO")
    setup_logging(log_level)
    
    logger.info("Starting MCDN Agent Service (Python)")
    
    # Override config with command line args
    if args.host:
        config["server"]["host"] = args.host
    if args.port:
        config["server"]["port"] = args.port
    
    # Create HTTP server
    server_address = (config["server"]["host"], config["server"]["port"])
    httpd = ThreadingHTTPServer(server_address, MCDNAgentHandler)
    
    logger.info(f"MCDN Agent serving at http://{config['server']['host']}:{config['server']['port']}")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("Shutting down...")
        httpd.shutdown()


if __name__ == "__main__":
    main()
