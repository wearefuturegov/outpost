import http.server
import socketserver
import os

PORT = 8000
JSON_FILE = "mock_result.json"


class JSONHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        with open(JSON_FILE, "rb") as f:
            self.wfile.write(f.read())


if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), JSONHandler) as httpd:
        print(f"Serving {JSON_FILE} at http://0.0.0.0:{PORT}/")
        httpd.serve_forever()
