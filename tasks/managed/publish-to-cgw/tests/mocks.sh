#!/usr/bin/env bash

MOCK_SERVER_SCRIPT="/tmp/mock_server.py"

cat << 'EOF' > "$MOCK_SERVER_SCRIPT"
import http.server
import logging
import socketserver
import json


class MockHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    all_files = [
        {
            "id": 3860,
            "type": "FILE",
            "hidden": False,
            "invisible": False,
            "description": "Red Hat OpenShift Local Sandbox Test",
            "shortURL": "/pub/cgw/product_code_1/1.2/release",
            "productVersionId": 4156076,
            "downloadURL": (
                "/content/origin/files/sha256/a8/a8fc7116a6bba3918552fad3186217bc904c3ec9d328"
                "85b1c3e969cf1ffc4224/release"
            ),
            "label": "release",
        },
        {
            "id": 3861,
            "type": "FILE",
            "hidden": False,
            "invisible": False,
            "description": "Red Hat OpenShift Local Sandbox Test",
            "shortURL": "/pub/cgw/product_code_1/1.2/release-darwin-amd64.gz",
            "productVersionId": 4156076,
            "downloadURL": (
                "/content/origin/files/sha256/dc/dc4eab578f6de0384cca9a0e13abce2ba877bcde8842"
                "76500a16a43bbec5903c/release-darwin-amd64.gz"
            ),
            "label": "release-darwin-amd64.gz",
        },
        {
            "id": 3862,
            "type": "FILE",
            "hidden": False,
            "invisible": False,
            "description": "Red Hat OpenShift Local Sandbox Test",
            "shortURL": "/pub/cgw/product_code_1/1.2/release-darwin-arm64.gz",
            "productVersionId": 4156076,
            "downloadURL": (
                "/content/origin/files/sha256/1d/1db0c38eff2bdd802aa18cc69403247c05d0cadf5e0d"
                "2aee35f9f7abfa3911fe/release-darwin-arm64.gz"
            ),
            "label": "release-darwin-arm64.gz",
        },
        {
            "id": 3863,
            "type": "FILE",
            "hidden": False,
            "invisible": False,
            "description": "Red Hat OpenShift Local Sandbox Test",
            "shortURL": ("/pub/cgw/product_code_1/1.2/release-linux-amd64.gz"),
            "productVersionId": 4156076,
            "downloadURL": (
                "/content/origin/files/sha256/39/39823330606a89d629fd7ae4549ad43233abade98f6a"
                "50bc1a62c21781cf270f/release-linux-amd64.gz"
            ),
            "label": "release-linux-amd64.gz",
        },
        {
            "id": 3864,
            "type": "FILE",
            "hidden": False,
            "invisible": False,
            "description": "Red Hat OpenShift Local Sandbox Test",
            "shortURL": ("/pub/cgw/product_code_1/1.2/release-linux-arm64.gz"),
            "productVersionId": 4156076,
            "downloadURL": (
                "/content/origin/files/sha256/d7/d7af17b3b2df1d5361979eb20a59431ad9ed723c46a0"
                "b18ec61f11a7f80609bf/release-linux-arm64.gz"
            ),
            "label": "release-linux-arm64.gz",
        },
    ]

    logging.basicConfig(level=logging.INFO, format="Mock Call: %(message)s")

    def log_message(self, format, *args):
        logging.info(format % args)

    def _send_json(self, data, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode("utf-8"))

    def do_GET(self):
        """
        GET requests:
        /products
        /products/<product_id>/versions
        /products/<product_id>/versions/<version_id>/files
        Else return 404
        """
        if self.path == "/products":
            response = [
                {
                    "id": 4010399,
                    "name": "product_name_1",
                    "productCode": "product_code_1",
                },
                {
                    "id": 5010399,
                    "name": "product_name_2",
                    "productCode": "product_code_2",
                },
            ]
            self._send_json(response)

        elif self.path == "/products/4010399/versions":
            response = [
                {
                    "id": 4156075,
                    "productId": 4010399,
                    "versionName": "1.1",
                },
                {
                    "id": 4156076,
                    "productId": 5010399,
                    "versionName": "1.2",
                },
            ]
            self._send_json(response)

        elif self.path.startswith("/products/") and self.path.endswith("/files"):
            self._send_json(self.all_files)
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        """
        POST requests:
        /products/<product_id>/versions/<version_id>/files
        Create a new file and return the new file ID
        if a short url or download url is present it returns an error
        """
        if "/versions/" in self.path and self.path.endswith("/files"):
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length)
            file_metadata = json.loads(body.decode("utf-8"))

            for existing in self.all_files:
                if any(
                    file_metadata.get(key) == existing[key]
                    for key in ["shortURL", "downloadURL"]
                ):
                    self.send_response(409)
                    self.send_header("Content-Type", "application/json")
                    self.end_headers()
                    self.wfile.write(
                        json.dumps({"File already exists!"}).encode("utf-8")
                    )
                    return

            file_id = len(self.all_files) + 100
            file_metadata["id"] = file_id
            self.all_files.append(file_metadata)
            self._send_json(file_id, status=201)
        else:
            self.send_response(404)
            self.end_headers()

    def do_DELETE(self):
        """
        DELETE requests:
        /products/<product_id>/versions/<version_id>/files/<file_id>
        Delete a file by id.
        """
        if "/versions/" in self.path and "/files/" in self.path:
            self.send_response(200)
            self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()


with socketserver.TCPServer(("0.0.0.0", 8080), MockHTTPRequestHandler) as httpd:
    httpd.serve_forever()
EOF

python3 "$MOCK_SERVER_SCRIPT" &
MOCK_SERVER_PID=$!
