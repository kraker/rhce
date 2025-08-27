# RHCE Knowledge Gaps Checklist - For Experienced Users

## 🎯 Self-Assessment for Production Ansible Users

*Use this checklist to identify what you need to focus on for exam success*

---

## 📋 How to Use This Checklist

**Rating Scale:**

- ✅ **Confident**: I can do this without reference materials
- ⚠️ **Uncertain**: I know the concept but need to verify syntax/approach
- ❌ **Gap**: I need to learn/practice this area

**Focus Strategy:**

- **✅ Items**: Quick review only
- **⚠️ Items**: Practice and verify, but don't over-study
- **❌ Items**: Intensive study and lab practice required

---

## 🔧 1. Automation Content Navigator

| Task | Rating | Notes |
|------|--------|-------|
| Run playbooks with `ansible-navigator run` | ⬜ | vs ansible-playbook |
| Navigate the TUI interface effectively | ⬜ | Interactive mode |
| Use stdout mode when appropriate | ⬜ | --mode stdout |
| Browse collections within navigator | ⬜ | :collections command |
| View module documentation in navigator | ⬜ | :doc module_name |
| Explore inventory using navigator | ⬜ | :inventory command |
| Debug failed tasks in TUI | ⬜ | Navigate to task details |
| Understand execution environments | ⬜ | Container vs host execution |
| Switch between interactive/stdout modes | ⬜ | Mode selection |
| Use navigator for syntax checking | ⬜ | --syntax-check |

**Quick Self-Test**: Can you run a playbook, debug a failure, and view module docs all within navigator?

---

## 📦 2. Content Collections & FQCN

| Task | Rating | Notes |
|------|--------|-------|
| Install collections with ansible-galaxy | ⬜ | collection install command |
| Use FQCN format consistently | ⬜ | namespace.collection.module |
| Know critical exam collections | ⬜ | builtin, posix, community.general |
| Write requirements.yml for collections | ⬜ | Collection dependencies |
| List installed collections | ⬜ | ansible-galaxy collection list |
| Browse collection modules | ⬜ | Find modules in collections |
| Use community.general storage modules | ⬜ | parted, lvg, lvol |
| Use ansible.posix system modules | ⬜ | firewalld, mount, seboolean |
| Troubleshoot "module not found" errors | ⬜ | Missing collection diagnosis |
| Configure collections_path | ⬜ | ansible.cfg setting |

**Quick Self-Test**: Can you install a collection and immediately use its modules with FQCN?

---

## 🖥️ 3. Control Node Setup & Configuration

| Task | Rating | Notes |
|------|--------|-------|
| Install Ansible on RHEL 9 | ⬜ | dnf install ansible-core |
| Create and configure ansible.cfg | ⬜ | All critical settings |
| Set up inventory in INI format | ⬜ | Groups and host variables |
| Set up inventory in YAML format | ⬜ | Nested group structure |
| Configure privilege escalation | ⬜ | become settings |
| Set default remote user | ⬜ | remote_user setting |
| Configure host key checking | ⬜ | Security vs convenience |
| Set up roles and collections paths | ⬜ | Custom paths |
| Test ansible.cfg precedence | ⬜ | Multiple config files |
| Validate inventory syntax | ⬜ | ansible-inventory commands |

**Quick Self-Test**: Can you set up a complete Ansible environment from scratch in 15 minutes?

---

## 🔐 4. Managed Node Configuration & SSH

| Task | Rating | Notes |
|------|--------|-------|
| Generate SSH key pairs | ⬜ | ssh-keygen with options |
| Distribute keys to managed nodes | ⬜ | ssh-copy-id |
| Set up passwordless authentication | ⬜ | End-to-end process |
| Configure sudo/become on managed nodes | ⬜ | NOPASSWD setup |
| Automate SSH key distribution | ⬜ | Using Ansible modules |
| Test connectivity with ansible ping | ⬜ | Basic connectivity |
| Troubleshoot SSH connection issues | ⬜ | Debug authentication |
| Set up ansible user account | ⬜ | Dedicated automation user |
| Configure privilege escalation | ⬜ | become_method, become_user |
| Handle SSH host key verification | ⬜ | StrictHostKeyChecking |

**Quick Self-Test**: Can you set up SSH authentication to a new system and test it in under 10 minutes?

---

## 📋 5. RHCSA Task Automation (Critical Exam Area)

### Package Management

| Task | Rating | Notes |
|------|--------|-------|
| Install packages with ansible.builtin.dnf | ⬜ | Single and multiple packages |
| Remove packages safely | ⬜ | state=absent |
| Install from URL/file | ⬜ | RPM files |
| Manage package groups | ⬜ | @group syntax |
| Configure repositories | ⬜ | yum_repository module |

### Service Management

| Task | Rating | Notes |
|------|--------|-------|
| Start/stop services with systemd module | ⬜ | state parameter |
| Enable/disable services | ⬜ | enabled parameter |
| Restart services conditionally | ⬜ | Handlers and notify |
| Reload systemd daemon | ⬜ | daemon_reload parameter |
| Check service status | ⬜ | Using setup module |

### Storage Management

| Task | Rating | Notes |
|------|--------|-------|
| Create partitions with parted | ⬜ | community.general.parted |
| Create volume groups | ⬜ | community.general.lvg |
| Create logical volumes | ⬜ | community.general.lvol |
| Create filesystems | ⬜ | community.general.filesystem |
| Mount filesystems | ⬜ | ansible.posix.mount |
| Manage /etc/fstab | ⬜ | Persistent mounts |

### User Management

| Task | Rating | Notes |
|------|--------|-------|
| Create users with user module | ⬜ | All common parameters |
| Create groups with group module | ⬜ | System vs regular groups |
| Set passwords securely | ⬜ | password_hash filter |
| Manage SSH keys for users | ⬜ | authorized_key module |
| Set user properties | ⬜ | shell, home, groups |

### File Management

| Task | Rating | Notes |
|------|--------|-------|
| Copy files with copy module | ⬜ | Local to remote |
| Deploy templates | ⬜ | Jinja2 templating |
| Modify file content | ⬜ | lineinfile, replace |
| Set file permissions | ⬜ | file module attributes |
| Create directories | ⬜ | Directory hierarchies |

### Firewall Management

| Task | Rating | Notes |
|------|--------|-------|
| Configure firewalld services | ⬜ | ansible.posix.firewalld |
| Open specific ports | ⬜ | Port ranges and protocols |
| Manage firewall zones | ⬜ | Zone assignments |
| Make changes permanent | ⬜ | permanent parameter |
| Apply changes immediately | ⬜ | immediate parameter |

### SELinux Management

| Task | Rating | Notes |
|------|--------|-------|
| Set SELinux booleans | ⬜ | ansible.posix.seboolean |
| Configure file contexts | ⬜ | sefcontext module |
| Apply context changes | ⬜ | restorecon command |
| Check SELinux status | ⬜ | Using facts |
| Handle SELinux troubleshooting | ⬜ | Common issues |

**Quick Self-Test**: Can you automate a complete LAMP stack setup including storage, users, services, and security?

---

## 🛠️ 6. Shell Script Conversion (Exam Requirement)

| Task | Rating | Notes |
|------|--------|-------|
| Analyze shell script logic | ⬜ | Understand flow |
| Convert conditional statements | ⬜ | if/then to when |
| Convert loops to Ansible loops | ⬜ | for to loop/with_items |
| Handle command execution | ⬜ | command vs shell |
| Manage script variables | ⬜ | Script vars to Ansible vars |
| Convert error handling | ⬜ | failed_when, ignore_errors |
| Preserve script functionality | ⬜ | Idempotency considerations |
| Test converted playbooks | ⬜ | Verify same results |

**Quick Self-Test**: Given a 20-line shell script, can you convert it to an equivalent playbook in 30 minutes?

---

## 📝 7. Playbook Development (Advanced Patterns)

| Task | Rating | Notes |
|------|--------|-------|
| Use conditionals with when | ⬜ | Complex logic |
| Implement loops effectively | ⬜ | loop, with_items variants |
| Handle task failures gracefully | ⬜ | failed_when, ignore_errors |
| Use blocks for error handling | ⬜ | block/rescue/always |
| Implement handlers properly | ⬜ | Notification patterns |
| Use register for task results | ⬜ | Variable capture |
| Delegate tasks appropriately | ⬜ | delegate_to, run_once |
| Use tags for selective execution | ⬜ | Tag strategies |
| Implement async task execution | ⬜ | Long-running tasks |
| Debug variables effectively | ⬜ | debug module usage |

**Quick Self-Test**: Can you write a complex playbook with error handling, loops, and conditionals?

---

## 🔐 8. Ansible Vault (Security)

| Task | Rating | Notes |
|------|--------|-------|
| Create encrypted files | ⬜ | ansible-vault create |
| Edit encrypted files | ⬜ | ansible-vault edit |
| Encrypt existing files | ⬜ | ansible-vault encrypt |
| Decrypt files when needed | ⬜ | ansible-vault decrypt |
| Change vault passwords | ⬜ | ansible-vault rekey |
| Use vault in playbooks | ⬜ | --ask-vault-pass |
| Set up vault password files | ⬜ | --vault-password-file |
| Encrypt single variables | ⬜ | encrypt_string |
| Use multiple vault IDs | ⬜ | --vault-id |
| Integrate vault with CI/CD | ⬜ | Automated workflows |

**Quick Self-Test**: Can you set up and use encrypted variables in a playbook execution?

---

## ⏰ 9. Exam Environment Constraints

| Task | Rating | Notes |
|------|--------|-------|
| Work entirely offline | ⬜ | No internet access |
| Use ansible-doc effectively | ⬜ | Primary documentation |
| Navigate documentation quickly | ⬜ | Fast lookups |
| Manage time effectively | ⬜ | 4-hour constraint |
| Debug without external help | ⬜ | Self-reliant troubleshooting |
| Use check mode for validation | ⬜ | Dry run testing |
| Test incrementally | ⬜ | Single task validation |
| Work with provided inventory | ⬜ | Predefined hosts/groups |
| Handle exam system constraints | ⬜ | Limited resources |
| Maintain focus under pressure | ⬜ | Stress management |

**Quick Self-Test**: Can you complete a complex automation task without any external references?

---

## 📊 Gap Analysis Summary

### Count Your Ratings

- **✅ Confident**: ___/90 items
- **⚠️ Uncertain**: ___/90 items  
- **❌ Gap**: ___/90 items

### Study Priority Calculation

- **70-90% Confident**: Light review, focus on uncertain items
- **50-69% Confident**: Moderate study needed, practice labs
- **Below 50% Confident**: Intensive study required

### Recommended Study Path Based on Gaps

**High Gap Count (>30 items)**:

- Start with Automation Content Navigator
- Master Content Collections next
- Focus heavily on RHCSA task automation
- Practice exam scenarios extensively

**Medium Gap Count (15-30 items)**:

- Target specific weak areas
- Practice time management
- Focus on exam-specific differences
- Do realistic practice scenarios

**Low Gap Count (<15 items)**:

- Quick review of uncertain items
- Practice exam timing
- Focus on exam environment adaptation
- Take practice exams

---

## 🎯 Action Plan Template

Based on your gap analysis, create a focused study plan:

### Week 1: Foundation Gaps

**Focus Areas**: _______________  
**Lab Time**: ___ hours/day  
**Key Tasks**: _______________

### Week 2: Advanced Skills  

**Focus Areas**: _______________  
**Lab Time**: ___ hours/day  
**Key Tasks**: _______________

### Week 3: Exam Simulation

**Focus Areas**: Time management, exam scenarios  
**Lab Time**: ___ hours/day  
**Key Tasks**: Full practice exams

### Week 4: Final Preparation

**Focus Areas**: Review weak areas, confidence building  
**Lab Time**: ___ hours/day  
**Key Tasks**: Final practice, review quick references

Remember: Your production experience is a major advantage. Focus on the gaps, not on re-learning what you already know!
