# Module 01: Automation Content Navigator

## 🎯 Learning Objectives

By the end of this module, you will:
- Master ansible-navigator for exam execution
- Understand execution environments and their benefits
- Navigate the interactive TUI effectively
- Know when to use navigator vs traditional tools
- Be comfortable with navigator's debugging features

## 📋 Why This Module Matters for Experienced Users

**The Reality:** You probably use `ansible-playbook` in production. The exam emphasizes `ansible-navigator`.

**The Gap:** Navigator introduces new concepts (execution environments, TUI) and different command patterns that you need to master for the exam.

**The Impact:** Understanding navigator is worth 15-20% of your exam success.

---

## 🚀 Automation Content Navigator Fundamentals

### What is Automation Content Navigator?

Automation Content Navigator is Red Hat's modern replacement for traditional Ansible CLI tools. It provides:

- **Container-based execution** via execution environments
- **Interactive text user interface (TUI)** for exploration
- **Enhanced debugging** and troubleshooting capabilities
- **Integrated collection and documentation** browsing

### Key Differences from Traditional Ansible

| Traditional Approach | Navigator Approach | Exam Preference |
|---------------------|-------------------|-----------------|
| `ansible-playbook site.yml` | `ansible-navigator run site.yml` | Navigator |
| `ansible-doc module` | `ansible-navigator doc module` | Either |
| `ansible-inventory --list` | `ansible-navigator inventory --list` | Either |
| Multiple tools | Single unified tool | Navigator |

---

## 🔧 Installation and Setup

### Installing Navigator

```bash
# On RHEL 9 (exam environment)
sudo dnf install ansible-navigator

# Verify installation
ansible-navigator --version

# Alternative: pip installation
pip3 install ansible-navigator
```

### Basic Configuration

```yaml
# ~/.ansible-navigator.yml or ./ansible-navigator.yml
---
ansible-navigator:
  execution-environment:
    image: registry.redhat.io/ubi8/ubi:latest
    enabled: true
  
  mode: interactive  # or 'stdout'
  
  inventory-columns:
    - ansible_host
    - ansible_user
    - ansible_connection
  
  playbook-artifact:
    enable: true
    save-as: artifacts/{playbook_name}-artifact-{ts_utc}.json
```

---

## 🎮 Interactive Mode (TUI)

### Launching Interactive Mode

```bash
# Start navigator in interactive mode
ansible-navigator

# Run playbook interactively
ansible-navigator run site.yml

# Explore collections interactively
ansible-navigator collections

# Browse inventory interactively
ansible-navigator inventory
```

### Navigation Commands

| Key | Action | Purpose |
|-----|--------|---------|
| `:help` | Show help | Learn navigation |
| `:collections` | Browse collections | Find modules |
| `:doc module_name` | View documentation | Module syntax |
| `:inventory` | View inventory | Check hosts |
| `:run` | Execute playbook | Run automation |
| `:q` or `:quit` | Exit | Leave navigator |
| `Enter` | Select item | Navigate deeper |
| `Esc` | Go back | Return to previous |

### Interactive Playbook Execution

```bash
ansible-navigator run site.yml
```

**In TUI Navigation:**
1. **Play overview**: See all plays in playbook
2. **Task details**: Drill down into specific tasks
3. **Host results**: View results per host
4. **Task output**: See detailed task execution
5. **Error analysis**: Debug failed tasks

---

## 📝 Command-Line Mode (stdout)

### Non-Interactive Execution

```bash
# Run in stdout mode (similar to ansible-playbook)
ansible-navigator run site.yml --mode stdout

# With verbosity
ansible-navigator run site.yml --mode stdout -v
ansible-navigator run site.yml --mode stdout -vvv

# Check mode
ansible-navigator run site.yml --mode stdout --check

# Syntax check
ansible-navigator run site.yml --syntax-check
```

### Common Command Patterns

```bash
# Execute with custom inventory
ansible-navigator run site.yml -i inventory.ini --mode stdout

# Limit to specific hosts
ansible-navigator run site.yml --limit webservers --mode stdout

# Start at specific task
ansible-navigator run site.yml --start-at-task "Install packages" --mode stdout

# Use vault password
ansible-navigator run site.yml --ask-vault-pass --mode stdout

# Pass extra variables
ansible-navigator run site.yml -e "env=prod" --mode stdout
```

---

## 🐳 Execution Environments

### Understanding Execution Environments

**Concept**: Containerized runtime environments that include:
- Python interpreter
- Ansible collections
- Python dependencies
- System tools

**Benefits**:
- Consistent execution across environments
- Isolation from host system
- Reproducible automation
- Version control for dependencies

### Default Execution Environment

```bash
# Navigator uses execution environment by default
ansible-navigator run site.yml

# Disable execution environment (run on host)
ansible-navigator run site.yml --execution-environment-enabled false

# Use specific execution environment image
ansible-navigator run site.yml --execution-environment-image registry.redhat.io/ubi8/ubi
```

### Managing Execution Environment Images

```bash
# List available images
ansible-navigator images

# Pull execution environment image
podman pull registry.redhat.io/ubi8/ubi:latest

# Build custom execution environment (advanced)
ansible-builder build --tag my-custom-ee .
```

---

## 📚 Documentation and Collection Browsing

### Module Documentation

```bash
# Browse modules interactively
ansible-navigator doc

# View specific module documentation
ansible-navigator doc ansible.builtin.dnf
ansible-navigator doc community.general.firewalld

# Search modules
ansible-navigator doc -l | grep firewall
```

### Collection Exploration

```bash
# Browse installed collections
ansible-navigator collections

# Interactive collection browsing:
# 1. Navigate to collection
# 2. Browse modules within collection
# 3. View module documentation
# 4. See usage examples
```

### Inventory Exploration

```bash
# View inventory structure
ansible-navigator inventory

# List specific inventory details
ansible-navigator inventory --list
ansible-navigator inventory --host hostname
ansible-navigator inventory --graph
```

---

## 🔍 Debugging and Troubleshooting

### Playbook Artifacts

Navigator automatically creates detailed execution artifacts:

```bash
# Artifacts are saved to:
# artifacts/{playbook_name}-artifact-{timestamp}.json

# View artifact contents
cat artifacts/site-artifact-2024-01-15T10-30-45.json | jq .
```

### Debug Information in TUI

**Interactive debugging workflow:**
1. Run playbook in TUI mode
2. Navigate to failed task
3. View detailed error output
4. Check task parameters
5. Examine host-specific results
6. Analyze gathered facts

### Verbose Output

```bash
# Standard verbose output
ansible-navigator run site.yml --mode stdout -v

# Maximum verbosity
ansible-navigator run site.yml --mode stdout -vvv

# Connection debugging
ansible-navigator run site.yml --mode stdout -vvvv
```

---

## 📋 Exam-Specific Usage Patterns

### Typical Exam Workflow

1. **Syntax Check**:
   ```bash
   ansible-navigator run site.yml --syntax-check
   ```

2. **Dry Run**:
   ```bash
   ansible-navigator run site.yml --check --mode stdout
   ```

3. **Execute with Monitoring**:
   ```bash
   ansible-navigator run site.yml --mode stdout -v
   ```

4. **Debug Issues** (if needed):
   ```bash
   ansible-navigator run site.yml  # Use TUI for debugging
   ```

### Time-Saving Tips

- **Use stdout mode** for faster execution during development
- **Use TUI mode** when you need to debug issues
- **Master navigation keys** to quickly find information
- **Use check mode** to validate before actual execution

---

## 💡 Best Practices for Exam Success

### When to Use Navigator vs Traditional Tools

**Use Navigator:**
- Running playbooks (exam preference)
- Debugging complex issues
- Exploring collections and documentation
- When you need detailed execution artifacts

**Traditional tools still valid:**
- Quick ad-hoc commands (`ansible all -m ping`)
- Simple documentation lookup (`ansible-doc module`)
- Inventory validation (`ansible-inventory --list`)

### Efficiency Tips

1. **Start with stdout mode** for speed
2. **Switch to TUI** when debugging needed
3. **Use check mode** to validate logic
4. **Master documentation browsing** for quick lookups
5. **Practice navigation keys** until they're muscle memory

---

## 🧪 Practical Lab Exercises

### Exercise 1: Basic Navigation
1. Install ansible-navigator
2. Create a simple playbook
3. Run it using both TUI and stdout modes
4. Explore the playbook artifact

### Exercise 2: Documentation Browsing
1. Use navigator to browse collections
2. Find the firewalld module
3. Read its documentation within navigator
4. Practice searching for modules

### Exercise 3: Debugging Workflow
1. Create a playbook with an intentional error
2. Run in TUI mode
3. Navigate to the failed task
4. Analyze the error details
5. Fix the issue and re-run

### Exercise 4: Inventory Exploration
1. Create a complex inventory with groups
2. Use navigator to explore the structure
3. View host details
4. Practice inventory navigation

---

## 🎯 Key Takeaways for Experienced Users

1. **Navigator is the exam standard** - practice with it instead of ansible-playbook
2. **TUI mode is powerful** for debugging but stdout mode is faster for known-good playbooks
3. **Execution environments** provide consistency but can be disabled if needed
4. **Documentation browsing** in navigator can be faster than separate ansible-doc commands
5. **Artifacts provide detailed execution history** - useful for complex scenarios

### Common Gotchas

- **Don't default to ansible-playbook** - use navigator
- **Remember stdout mode** - TUI isn't always necessary
- **Navigation keys matter** - practice them for efficiency
- **Execution environments** - understand when they help vs hinder
- **Check mode works the same** - use it for validation

Master navigator now, and it will serve you well on exam day!