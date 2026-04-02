
## Golang dev
export PATH="/go/bin:/usr/local/go/bin:$PATH"

# Install fixed Air version for reproducible builds.
go install github.com/air-verse/air@v1.61.7

# Install tools for go 1.24
go install -v golang.org/x/tools/gopls@v0.18.1

go install -v github.com/go-delve/delve/cmd/dlv@v1.24.0 && \
go install -v honnef.co/go/tools/cmd/staticcheck@v0.6.1
