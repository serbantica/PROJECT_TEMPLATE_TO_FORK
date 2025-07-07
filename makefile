.PHONY: init logs checkpoint clean setup devtools run test validate help

# 💥 Initialize project structure
init:
	mkdir -p infra src/orchestrator src/agents src/api
	mkdir -p configs pipelines tests
	mkdir -p docs logs .checkpoints
	touch README.md
	touch docs/charter.md docs/ethics.md docs/cost_control.md
	touch docs/architecture.md docs/working_agreement.md docs/changelog.md
	touch tests/__init__.py
	echo "✅ Initialized project structure."

# 📓 Create today's log file
logs:
	@DATE=$$(date +%Y-%m-%d); \
	FILE=logs/$${DATE}_session.md; \
	echo "# Log — $${DATE}" > $$FILE; \
	echo "Created log file: $$FILE"

# 📌 Mark phase completion
checkpoint:
	@DATE=$$(date +%Y-%m-%d); \
	echo "✅ Phase checkpoint saved on $${DATE}" > .checkpoints/phase0_complete.md

# 🧹 Clean all non-Git files
clean:
	rm -rf logs/* .checkpoints/* docs/*.md
	echo "🧨 Cleaned logs, checkpoints, and docs"

# 🐍 Setup Python environment using uv (https://github.com/astral-sh/uv)
setup:
	@echo "🔧 Installing uv and setting up Python environment..."
	@python3 -m pip install --upgrade pip
	@python3 -m pip install uv
	@uv venv .venv
	@uv init || echo "pyproject.toml already exists"
	@uv sync
	@echo "✅ Python virtual environment set up at .venv/"

# 🧪 Install dev dependencies
devtools:
	@echo "🛠️  Installing development tools..."
	@. .venv/bin/activate && uv add --dev ruff pytest black
	@echo "✅ Development tools installed"

# 🔍 Validate environment
validate:
	@echo "🔍 Validating project setup..."
	@./validate_bootstrap.sh

# 🏃 Run the application
run:
	@echo "🚀 Running application..."
	@. .venv/bin/activate && python main.py

# 🧪 Run tests
test:
	@echo "🧪 Running tests..."
	@. .venv/bin/activate && python -m pytest tests/ -v

# 📋 Show available commands
help:
	@echo "Available commands:"
	@echo "  make validate  - Validate environment setup"
	@echo "  make init      - Initialize project structure"
	@echo "  make setup     - Setup Python environment with uv"
	@echo "  make logs      - Create today's log file"
	@echo "  make checkpoint- Mark phase completion"
	@echo "  make devtools  - Install development tools"
	@echo "  make run       - Run the main application"
	@echo "  make test      - Run tests"
	@echo "  make clean     - Clean temporary files"
	@echo "  make help      - Show this help message"
	@echo ""
	@echo "🚀 Quick start for forked repository:"
	@echo "  1. ./validate_bootstrap.sh"
	@echo "  2. ./project_bootstrap.sh [project-name]"
	@echo "  3. make run"
