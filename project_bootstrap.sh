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
    # Convert project name to lowercase with hyphens (standard Python package naming)
    PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
    PROJECT_PACKAGE=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')
    
    sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_SLUG/g" pyproject.toml
    sed -i.bak "s/PROJECT_PACKAGE_PLACEHOLDER/$PROJECT_PACKAGE/g" pyproject.toml
    rm -f pyproject.toml.bak
    echo "✅ Updated pyproject.toml with project name: $PROJECT_SLUG"
fi

# Update main.py if it exists
if [ -f "main.py" ]; then
    sed -i.bak "s/Hello from .*/Hello from $PROJECT_NAME!/" main.py
    sed -i.bak "s/PROJECT_PLACEHOLDER/$PROJECT_NAME/" main.py
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
    # First initialize the project structure
    echo "🏗️  Initializing project structure..."
    make init
    
    # Create the src package directory structure
    PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')
    mkdir -p "src/$PROJECT_SLUG"
    
    # Create __init__.py for the package
    cat > "src/$PROJECT_SLUG/__init__.py" << EOF
"""$PROJECT_NAME - A modern Python project template."""

__version__ = "0.1.0"
__author__ = "Your Name"
__email__ = "your.email@example.com"
EOF
    
    # Now setup the environment
    make setup
    echo "✅ Python environment setup completed"
else
    echo "❌ Python3 not found. Please install Python 3.11+ first."
    exit 1
fi

# ===============================================
# 3. Create main.py if needed
# ===============================================
echo "📝 Creating main application file..."

# Create main.py if it doesn't exist
if [ ! -f "main.py" ]; then
    cat > main.py << 'EOF'
"""Main application entry point."""


def main():
    """Main application function."""
    print("Hello from PROJECT_PLACEHOLDER!")


if __name__ == "__main__":
    main()
EOF
    echo "✅ Created main.py"
fi

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
# 5.5. Create basic test files
# ===============================================
echo "🧪 Creating basic test files..."

# Create __init__.py for tests package
cat > tests/__init__.py << 'EOF'
"""Tests package for the project."""
EOF

# Create basic test file
cat > tests/test_main.py << 'EOF'
"""Basic tests for the main module."""

import sys
import os
import pytest

# Add src directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))


def test_main_function_exists():
    """Test that the main function exists and can be imported."""
    import main
    assert hasattr(main, 'main')
    assert callable(main.main)


def test_main_function_runs():
    """Test that the main function runs without errors."""
    import main
    # This should not raise an exception
    try:
        main.main()
    except SystemExit:
        # main() might call sys.exit(), which is fine
        pass


def test_project_structure():
    """Test that the project structure is in place."""
    # Check that key directories exist
    assert os.path.exists("src")
    assert os.path.exists("docs")
    assert os.path.exists("configs")
    assert os.path.exists("logs")
    
    # Check that main.py exists
    assert os.path.exists("main.py")
    
    # Check that pyproject.toml exists
    assert os.path.exists("pyproject.toml")
EOF

echo "✅ Basic test files created"

# ===============================================
# 5.6. Create AI Project Charter Tool
# ===============================================
echo "✨ Creating AI Project Charter Tool..."
CHARTER_TOOL_DIR="charter_tool"
mkdir -p "$CHARTER_TOOL_DIR"

# Create charter_tool/streamlit_app.py
cat > "$CHARTER_TOOL_DIR/streamlit_app.py" << 'EOF'
"""
AI Project Charter & Configuration Tool
A Streamlit multi-page application for AI project planning and configuration.
Generated by project_bootstrap.sh
"""
import streamlit as st
import os
import json
from datetime import datetime
from typing import Dict, List, Any

# Try to import yaml, use json as fallback
try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

# Configure the page
st.set_page_config(
    page_title="AI Project Charter Tool",
    page_icon="🎯",
    layout="wide",
    initial_sidebar_state="expanded"
)

# --- Utility Functions ---
def save_config_to_file():
    """Save current configuration to configs directory"""
    os.makedirs("configs", exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    project_name_slug = st.session_state.project_config.get('project_name', 'project').lower().replace(' ', '_')
    filename = f"configs/project_config_{project_name_slug}_{timestamp}.json"
    
    with open(filename, 'w') as f:
        json.dump(st.session_state.project_config, f, indent=2, default=str)
    
    return filename

def load_config_from_file(filename):
    """Load configuration from file"""
    try:
        with open(filename, 'r') as f:
            config = json.load(f)
        st.session_state.project_config.update(config)
        # Ensure all keys are present after loading
        initialize_session_state(force=False) 
        return True
    except Exception as e:
        st.error(f"Error loading config: {e}")
        return False

def generate_ai_response(prompt: str) -> str:
    """Generate AI-like response based on prompt keywords"""
    prompt_lower = prompt.lower()
    responses = {
        ('problem', 'solve', 'issue'): "Great! Understanding the problem is crucial. Can you be more specific about the current pain points and what metrics you'd use to measure success?",
        ('user', 'customer', 'people'): "User analysis is key! Tell me more about their technical skills and how they currently handle this process. Are they technical or non-technical users?",
        ('interface', 'ui', 'interaction'): "Interface design is important! Are you thinking of a chat interface, web dashboard, API, or something else? What would work best for your users?",
        ('architecture', 'system', 'components'): "Let's break down the system architecture. What specialized functions do you need? Think about data processing, analysis, storage, and user interface components.",
        ('budget', 'cost', 'constraint'): "Constraints help guide technical decisions. What's your budget, performance requirements, and any compliance needs like GDPR or security standards?",
        ('timeline', 'schedule', 'deadline'): "Timeline planning is crucial! What's your target go-live date? Should we plan for phases like prototype, development, testing, and deployment?"
    }
    for keywords, response in responses.items():
        if any(word in prompt_lower for word in keywords):
            return response
    return "That's an interesting point! Can you elaborate on how this fits into your overall project goals? I'm here to help you structure your AI project effectively."

def update_config_from_chat(prompt: str):
    """Update project configuration based on chat content"""
    st.session_state.project_config['chat_history'].append({
        'timestamp': datetime.now().isoformat(),
        'content': prompt
    })

def validate_configuration(config: Dict) -> Dict:
    """Validate the current configuration"""
    results = {}
    if config.get('project_name'):
        results['Project Name'] = {'valid': True, 'message': 'Project name is set'}
    else:
        results['Project Name'] = {'valid': False, 'message': 'Project name is required'}
    
    if config.get('problem_statement') and len(config['problem_statement']) > 20:
        results['Problem Statement'] = {'valid': True, 'message': 'Problem statement is detailed'}
    else:
        results['Problem Statement'] = {'valid': False, 'message': 'Problem statement needs more detail'}
    
    if config.get('users'):
        results['Users'] = {'valid': True, 'message': f"{len(config['users'])} user types defined"}
    else:
        results['Users'] = {'valid': False, 'message': 'User types need to be defined'}
        
    if config.get('system_components') and len(config.get('system_components', [])) >= 3:
        results['Architecture'] = {'valid': True, 'message': 'System components are defined'}
    else:
        results['Architecture'] = {'valid': False, 'message': 'Need at least 3 system components'}
    return results

def generate_project_charter() -> str:
    """Generate project charter based on current configuration"""
    config = st.session_state.project_config
    charter = f"""# {config.get('project_name', 'AI Project')} Charter
Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
## Project Overview
**Problem Statement:** {config.get('problem_statement', 'Not defined')}
## User Analysis
**Target Users:** {", ".join(config.get('users', []))}
**Interaction Patterns:** {", ".join(config.get('interaction_patterns', []))}
"""
    return charter

def initialize_session_state(force=False):
    """Initialize or update the session state."""
    if 'project_config' not in st.session_state or force:
        st.session_state.project_config = {
            'project_name': '', 'problem_statement': '',
            'users': [], 'interaction_patterns': [], 'system_components': [],
            'constraints': {}, 'success_metrics': {}, 'timeline': {},
            'chat_history': [], 'current_step': 'concept',
            'completion_status': {}
        }
    
    required_keys = {
        'project_name': '', 'problem_statement': '', 'users': [], 
        'interaction_patterns': [], 'system_components': [], 'constraints': {}, 
        'success_metrics': {}, 'timeline': {}, 'chat_history': [], 
        'current_step': 'concept', 'completion_status': {}
    }
    for key, default_value in required_keys.items():
        st.session_state.project_config.setdefault(key, default_value)

    required_completion_keys = [
        'Problem Definition', 'User Analysis', 'Interaction Design', 
        'Architecture', 'Constraints', 'Success Metrics', 'Timeline'
    ]
    for key in required_completion_keys:
        st.session_state.project_config.setdefault('completion_status', {}).setdefault(key, False)

    if 'chat_messages' not in st.session_state:
        st.session_state.chat_messages = []

# --- App Initialization ---
initialize_session_state()

# --- Sidebar ---
with st.sidebar:
    st.title("🎯 AI Project Charter")
    page = st.selectbox("Navigate", ["Dashboard", "Interactive Chat", "Configuration", "Export & Deploy"])
    st.divider()
    st.subheader("📊 Progress")
    progress_sections = [
        "Problem Definition", "User Analysis", "Interaction Design",
        "Architecture", "Constraints", "Success Metrics", "Timeline"
    ]
    for section in progress_sections:
        status = st.session_state.project_config.get('completion_status', {}).get(section, False)
        st.write(f"{ '✅' if status else '⏳'} {section}")
    
    st.divider()
    st.subheader("🚀 Quick Actions")
    if st.button("Reset Project"):
        initialize_session_state(force=True)
        st.rerun()
    
    if st.button("Save Progress"):
        filename = save_config_to_file()
        st.success(f"Progress saved to {filename}")

# --- Main Content ---
if page == "Dashboard":
    st.title("🎯 AI Project Dashboard")
    col1, col2 = st.columns([2, 1])
    
    with col1:
        st.subheader("Project Overview")
        project_name = st.text_input("Project Name", st.session_state.project_config.get('project_name', ''), placeholder="Enter your AI project name")
        st.session_state.project_config['project_name'] = project_name
        
        problem_statement = st.text_area("Problem Statement", st.session_state.project_config.get('problem_statement', ''), placeholder="What specific problem are you solving?", height=100)
        st.session_state.project_config['problem_statement'] = problem_statement
        
        st.session_state.project_config['completion_status']['Problem Definition'] = bool(project_name and problem_statement and len(problem_statement) > 20)

        # Tabs for different sections
        tab1, tab2, tab3, tab4 = st.tabs(["👥 Users & Interaction", "🏗️ Architecture", "📏 Constraints & Metrics", "📅 Timeline"])
        
        with tab1:
            st.subheader("User Analysis")
            user_types = st.multiselect("Primary User Types", ["Technical Users", "Business Users", "End Customers"], default=st.session_state.project_config.get('users', []))
            st.session_state.project_config['users'] = user_types
            
            interaction_patterns = st.multiselect("Interaction Patterns", ["Chat Interface", "API Calls", "Web Dashboard"], default=st.session_state.project_config.get('interaction_patterns', []))
            st.session_state.project_config['interaction_patterns'] = interaction_patterns
            
            st.session_state.project_config['completion_status']['User Analysis'] = bool(user_types)
            st.session_state.project_config['completion_status']['Interaction Design'] = bool(interaction_patterns)

    with col2:
        st.subheader("🎯 Project Health")
        total_sections = len(progress_sections)
        completed_sections = sum(1 for status in st.session_state.project_config.get('completion_status', {}).values() if status)
        completion_percentage = (completed_sections / total_sections) * 100 if total_sections > 0 else 0
        st.metric("Completion", f"{completion_percentage:.0f}%")
        st.progress(completion_percentage / 100)
        
        st.subheader("🔧 Quick Config")
        config_files = []
        if os.path.exists("configs"):
            config_files = sorted([f for f in os.listdir("configs") if f.endswith('.json')], reverse=True)
        
        if config_files:
            selected_config = st.selectbox("Load Previous Config", ["None"] + config_files)
            if selected_config != "None" and st.button("Load Config"):
                if load_config_from_file(f"configs/{selected_config}"):
                    st.success("Configuration loaded!")
                    st.rerun()

elif page == "Interactive Chat":
    st.title("🤖 Interactive Project Planning Chat")
    # Chat implementation
    if prompt := st.chat_input("Ask about your project..."):
        st.session_state.chat_messages.append({"role": "user", "content": prompt})
        ai_response = generate_ai_response(prompt)
        st.session_state.chat_messages.append({"role": "assistant", "content": ai_response})
        update_config_from_chat(prompt)
        st.rerun()

elif page == "Configuration":
    st.title("⚙️ Advanced Configuration")
    config_json = st.text_area("Edit Configuration (JSON)", value=json.dumps(st.session_state.project_config, indent=2), height=400)
    if st.button("Update Configuration"):
        try:
            new_config = json.loads(config_json)
            st.session_state.project_config.update(new_config)
            st.success("Configuration updated!")
        except json.JSONDecodeError as e:
            st.error(f"Invalid JSON: {e}")

elif page == "Export & Deploy":
    st.title("📤 Export & Deploy")
    st.subheader("Generate Project Files")
    if st.button("📋 Generate Project Charter"):
        charter_content = generate_project_charter()
        st.text_area("Project Charter (Markdown)", charter_content, height=300)
        os.makedirs("docs", exist_ok=True)
        with open("docs/generated_charter.md", "w") as f:
            f.write(charter_content)
        st.success("Charter saved to docs/generated_charter.md")
EOF

# Create charter_tool/run_streamlit.sh
cat > "$CHARTER_TOOL_DIR/run_streamlit.sh" << 'EOF'
#!/bin/bash
# 🚀 AI Project Charter Tool Runner
echo "🎯 Starting AI Project Charter Tool..."
APP_PATH="charter_tool/streamlit_app.py"
if [ ! -f "$APP_PATH" ]; then
    echo "❌ $APP_PATH not found. Run this from the project root."
    exit 1
fi
streamlit run "$APP_PATH" --server.port=8502 --server.address=0.0.0.0
EOF
chmod +x "$CHARTER_TOOL_DIR/run_streamlit.sh"

# Create charter_tool/demo_charter_tool.sh
cat > "$CHARTER_TOOL_DIR/demo_charter_tool.sh" << 'EOF'
#!/bin/bash
# 🎯 AI Project Charter Tool Demo
echo "Running AI Project Charter Tool Demo..."
echo "Please run the tool using 'make streamlit' or 'bash charter_tool/run_streamlit.sh'"
EOF
chmod +x "$CHARTER_TOOL_DIR/demo_charter_tool.sh"

# Create charter_tool/STREAMLIT_README.md
cat > "$CHARTER_TOOL_DIR/STREAMLIT_README.md" << 'EOF'
# 🎯 AI Project Charter Tool
This tool helps you plan your AI projects.
## How to Run
From your project root, run:
```bash
make streamlit
```
Or directly:
```bash
bash charter_tool/run_streamlit.sh
```
EOF

# Create charter_tool/example_usage.py
cat > "$CHARTER_TOOL_DIR/example_usage.py" << 'EOF'
"""Example usage of the generated configurations."""
import json, os
from pathlib import Path

def load_latest_config():
    config_dir = Path("configs")
    if not config_dir.exists():
        print("No configs directory found.")
        return None
    
    config_files = list(config_dir.glob("project_config_*.json"))
    if not config_files:
        print("No configuration files found.")
        return None
        
    latest_config_path = max(config_files, key=os.path.getctime)
    with open(latest_config_path, 'r') as f:
        return json.load(f)

if __name__ == "__main__":
    config = load_latest_config()
    if config:
        print("✅ Successfully loaded latest project configuration:")
        print(json.dumps(config, indent=2))
EOF

echo "✅ AI Project Charter Tool created successfully."


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
