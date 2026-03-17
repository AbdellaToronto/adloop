"""AdLoop — MCP server connecting Google Ads + GA4 + codebase."""

__version__ = "0.1.0"


def main() -> None:
    """Entry point for `adloop` console script."""
    from adloop.server import mcp

    # StdIO MCP clients need stdout reserved for JSON-RPC only.
    mcp.run(show_banner=False, log_level="ERROR")
