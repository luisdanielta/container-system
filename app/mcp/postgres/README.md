# PostgreSQL MCP Server

Model Context Protocol (MCP) server providing read-only access to PostgreSQL databases. This component enables Large Language Models (LLMs) to perform schema introspection and execute SQL queries within controlled environments.

## Technical Specifications

### Tools
- **`query`**: Executes SQL `SELECT` statements.
  - **Parameters**: `sql` (string).
  - **Isolation**: Queries are forced within a `READ ONLY` transaction to ensure data integrity.

### Resources
- **Table Schemas** (`postgres://<host>/<table>/schema`): Exposes table metadata in JSON format, including column names and native Postgres data types.

---

## Infrastructure Configuration (Docker Compose)

For persistent deployments in internal networks with static IP addressing, use the following configuration. It is imperative to keep `stdin_open` and `tty` active to allow the MCP protocol data flow.

```yaml
services:
  xaiena_server:
    image: mcp/postgres
    container_name: mcp_xaiena
    restart: unless-stopped
    stdin_open: true 
    tty: true        
    command: ["postgresql://<user>:<password>@10.10.3.154:5432/<database>"]
    networks:
      network_service:
        ipv4_address: 10.10.3.100

networks:
  network_service:
    external: true
```

---

## Client Implementation

### Claude Desktop
To integrate this service into Claude Desktop, edit the `claude_desktop_config.json` file by linking the container process:

```json
{
  "mcpServers": {
    "postgres-xaiena": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "mcp_xaiena",
        "cat" 
      ]
    }
  }
}
```

### Ephemeral Execution via NPX
For rapid development testing without infrastructure deployment:

```json
{
  "mcpServers": {
    "postgres-local": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://<user>:<password>@localhost:5432/<database>"
      ]
    }
  }
}
```

---

## Build and Development

To generate the image locally after source code modifications:

```sh
docker build -t mcp/postgres .
```

## License

Distributed under the **MIT License**. This server is an implementation of open standards for interoperability between AI models and relational database systems.