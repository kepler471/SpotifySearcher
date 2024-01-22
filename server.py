import http.server
import socketserver
import urllib.parse as urlparse

class OAuthHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Parse the URL query
        query = urlparse.urlparse(self.path).query
        query_components = urlparse.parse_qs(query)

        # Check if 'code' is in the query
        if 'code' in query_components:
            self.authorization_code = query_components['code'][0]
            # Display a simple response in the browser
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b"<html><body><h1>Authorization code received</h1></body></html>")
            print(f"Authorization code: {self.authorization_code}")
        else:
            # Handle the case where 'code' is not in the query
            self.send_error(400, "Authorization code not found in the request")

# Set the port and create the server
port = 8080 # You can choose any available port
with socketserver.TCPServer(("localhost", port), OAuthHandler) as httpd:
    print(f"Server started at http://localhost:{port}")
    httpd.serve_forever()

