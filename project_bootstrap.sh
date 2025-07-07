#!/bin/bash

# 🚀 Project Bootstrap Script (Fork Version)
# This script transforms a forked template into a complete project
# Usage: ./project_bootstrap.sh [project_name]

set -e  # Exit on any error

# Use provided project name or default to current directory name
PROJECT_NAME=${1:-$(basename "$(pwd)")}
PROJECT_DIR=$(pwd)

echo "🎯 Bootstrapping forked project: $PROJECT_NAME"
echo "📂 Working directory: $PROJECT_DIR"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. This script is designed for forked repositories."
    echo "💡 Make sure you're in the root of your forked repository"
    exit 1
fi

# ===============================================
# 1. Update existing files with project name
# ===============================================
echo "📝 Updating project files with name: $PROJECT_NAME"

# Update pyproject.toml if it exists
if [ -f "pyproject.toml" ]; then
    sed -i.bak "s/name = \".*\"/name = \"$PROJECT_NAME\"/" pyproject.toml
    rm -f pyproject.toml.bak
    echo "✅ Updated pyproject.toml with project name"
fi

# Update main.py if it exists
if [ -f "main.py" ]; then
    sed -i.bak "s/Hello from .*/Hello from $PROJECT_NAME!/" main.py
    rm -f main.py.bak
    echo "✅ Updated main.py with project name"
fi

# Update README.md if it exists
if [ -f "README.md" ]; then
    sed -i.bak "1s/.*/# $PROJECT_NAME/" README.md
    rm -f README.md.bak
    echo "✅ Updated README.md with project name"
fi

# Update documentation templates with project name
if [ -f "docs/charter.md" ]; then
    sed -i.bak "1s/.*/# $PROJECT_NAME Charter/" docs/charter.md
    rm -f docs/charter.md.bak
    echo "✅ Updated docs/charter.md with project name"
fi

# Update package __init__.py files
if [ -f "src/__init__.py" ]; then
    sed -i.bak "s/\"\"\".*package\.\"\"\"/\"\"\"$PROJECT_NAME package.\"\"\"/" src/__init__.py
    rm -f src/__init__.py.bak
    echo "✅ Updated src/__init__.py with project name"
fi

# ===============================================
# 2. Setup Python environment
# ===============================================
echo ""
echo "🔧 Setting up Python environment..."
if command -v python3 &> /dev/null; then
    make setup
    echo "✅ Python environment setup completed"
else
    echo "❌ Python3 not found. Please install Python 3.11+ first."
    exit 1
fi

# ===============================================
# 3. Initialize project structure (if needed)
# ===============================================
echo "🏗️  Ensuring project structure is complete..."
make init
echo "✅ Project structure verified"

# ===============================================
# 4. Create session log
# ===============================================
echo "📝 Creating initial session log..."
make logs
echo "✅ Session log created"

# ===============================================
# 5. Install development tools
# ===============================================
echo "🛠️  Installing development tools..."
make devtools
echo "✅ Development tools installed"

# ===============================================
# 6. Run validation tests
# ===============================================
echo "🧪 Running validation tests..."
make test
echo "✅ All tests passed"

# ===============================================
# 7. Clean up template files
# ===============================================
echo "🧹 Cleaning up template-specific files..."

# Remove template-specific files
rm -f TEMPLATE_README.md
rm -f docs/PROJECT_BOOTSTRAP_GUIDE.md

# Remove this bootstrap script and validation script
echo "📝 Creating setup completion log..."
cat > BOOTSTRAP_COMPLETE.md << EOF
# Bootstrap Complete

✅ Project: $PROJECT_NAME
📅 Date: $(date)
🏗️  Bootstrap completed successfully

## What was set up:
- Python virtual environment with uv
- Complete project structure
- Documentation templates
- Development tools (ruff, pytest, black)
- Git repository ready for development

## Next steps:
1. Customize docs/charter.md with your project details
2. Update dependencies in pyproject.toml
3. Implement your features in src/
4. Write comprehensive tests
5. Set up CI/CD pipeline
6. Deploy your application

## Commands available:
- \`make help\` - Show all available commands
- \`make run\` - Run the application
- \`make test\` - Run tests
- \`make devtools\` - Install development tools
- \`make logs\` - Create session logs
- \`make checkpoint\` - Mark milestones

Your project is ready for development! 🚀
EOF

# ===============================================
# 8. Git commit the changes
# ===============================================
echo "📌 Committing bootstrap changes..."

# Add all files
git add .

# Commit the bootstrap
git commit -m "Bootstrap project: $PROJECT_NAME

- Set up Python environment with uv
- Initialized project structure
- Created documentation templates
- Installed development tools
- Removed template files
- Ready for development"

echo "✅ Bootstrap changes committed"

# ===============================================
# 9. Final summary
# ===============================================
echo ""
echo "🎉 Fork Bootstrap Complete!"
echo "============================"
echo "✅ Project name: $PROJECT_NAME"
echo "✅ Python environment set up with uv"
echo "✅ Project structure initialized"
echo "✅ Documentation templates created"
echo "✅ Development tools installed"
echo "✅ Tests passing"
echo "✅ Template files cleaned up"
echo "✅ Changes committed to git"
echo ""
echo "📋 Next steps:"
echo "1. Push changes to your GitHub repository:"
echo "   git push origin main"
echo "2. Customize docs/charter.md with your project details"
echo "3. Update dependencies in pyproject.toml"
echo "4. Start implementing your features in src/"
echo "5. Write comprehensive tests"
echo "6. Set up CI/CD pipeline"
echo ""
echo "🚀 Your project '$PROJECT_NAME' is ready for development!"
echo "Use 'make help' to see all available commands."
echo ""
echo "📖 Check BOOTSTRAP_COMPLETE.md for detailed setup information."
