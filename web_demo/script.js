// TaskManager Demo JavaScript

document.addEventListener('DOMContentLoaded', function() {
    initializeDemo();
});

function initializeDemo() {
    setupThemeToggle();
    setupInteractiveElements();
    setupTaskInteractions();
    setupQuickEntry();
}

// Theme Toggle
function setupThemeToggle() {
    const themeToggle = document.getElementById('themeToggle');
    const body = document.body;
    
    // Check for saved theme preference or default to light mode
    const savedTheme = localStorage.getItem('theme') || 'light';
    setTheme(savedTheme);
    
    themeToggle.addEventListener('click', function() {
        const currentTheme = body.getAttribute('data-theme') || 'light';
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        setTheme(newTheme);
        localStorage.setItem('theme', newTheme);
    });
}

function setTheme(theme) {
    const body = document.body;
    const themeToggle = document.getElementById('themeToggle');
    
    body.setAttribute('data-theme', theme);
    
    if (theme === 'dark') {
        themeToggle.textContent = '☀️ Light Mode';
    } else {
        themeToggle.textContent = '🌙 Dark Mode';
    }
}

// Interactive Elements
function setupInteractiveElements() {
    // Sidebar items
    const sidebarItems = document.querySelectorAll('.sidebar-item');
    sidebarItems.forEach(item => {
        item.addEventListener('click', function() {
            // Remove active class from all items
            sidebarItems.forEach(i => i.classList.remove('active'));
            // Add active class to clicked item
            this.classList.add('active');
            
            // Update task list based on selection
            updateTaskList(this.querySelector('.label').textContent);
        });
    });
    
    // View selector buttons
    const viewButtons = document.querySelectorAll('.view-btn');
    viewButtons.forEach(button => {
        button.addEventListener('click', function() {
            viewButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            
            // Simulate view change
            showViewChangeAnimation();
        });
    });
    
    // Toolbar buttons
    const toolbarButtons = document.querySelectorAll('.toolbar-btn');
    toolbarButtons.forEach(button => {
        button.addEventListener('click', function() {
            // Add click animation
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = '';
            }, 150);
        });
    });
}

// Task Interactions
function setupTaskInteractions() {
    // Task checkboxes
    const taskCheckboxes = document.querySelectorAll('.task-checkbox');
    taskCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('click', function(e) {
            e.stopPropagation();
            toggleTaskCompletion(this);
        });
    });
    
    // Subtask checkboxes
    const subtaskCheckboxes = document.querySelectorAll('.subtask-checkbox');
    subtaskCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('click', function() {
            toggleSubtaskCompletion(this);
        });
    });
}

function toggleTaskCompletion(checkbox) {
    const taskItem = checkbox.closest('.task-item');
    const isCompleted = checkbox.classList.contains('checked');
    
    if (isCompleted) {
        // Mark as incomplete
        checkbox.classList.remove('checked');
        checkbox.textContent = '';
        taskItem.classList.remove('completed');
    } else {
        // Mark as complete
        checkbox.classList.add('checked');
        checkbox.textContent = '✓';
        taskItem.classList.add('completed');
        
        // Show completion animation
        showCompletionAnimation(taskItem);
    }
}

function toggleSubtaskCompletion(checkbox) {
    const subtaskText = checkbox.nextElementSibling;
    const isCompleted = checkbox.classList.contains('checked');
    
    if (isCompleted) {
        checkbox.classList.remove('checked');
        checkbox.textContent = '';
        subtaskText.classList.remove('completed');
    } else {
        checkbox.classList.add('checked');
        checkbox.textContent = '✓';
        subtaskText.classList.add('completed');
    }
    
    // Update progress bar if in main task list
    updateSubtaskProgress();
}

function updateSubtaskProgress() {
    const progressBars = document.querySelectorAll('.progress-fill');
    progressBars.forEach(bar => {
        // Simulate progress update
        const currentWidth = parseInt(bar.style.width) || 60;
        const newWidth = Math.min(currentWidth + 20, 100);
        bar.style.width = newWidth + '%';
        
        // Update progress text
        const progressText = bar.closest('.subtask-progress').querySelector('.progress-text');
        if (progressText) {
            const total = 5;
            const completed = Math.floor((newWidth / 100) * total);
            progressText.textContent = `${completed}/${total}`;
        }
    });
}

// Quick Entry
function setupQuickEntry() {
    const quickEntryInput = document.querySelector('.quick-entry input');
    const addButton = document.querySelector('.quick-entry .add-btn');
    
    quickEntryInput.addEventListener('input', function() {
        const hasText = this.value.trim().length > 0;
        addButton.style.opacity = hasText ? '1' : '0.5';
        addButton.style.pointerEvents = hasText ? 'auto' : 'none';
    });
    
    quickEntryInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && this.value.trim()) {
            addNewTask(this.value.trim());
            this.value = '';
            addButton.style.opacity = '0.5';
        }
    });
    
    addButton.addEventListener('click', function() {
        const input = quickEntryInput.value.trim();
        if (input) {
            addNewTask(input);
            quickEntryInput.value = '';
            this.style.opacity = '0.5';
        }
    });
}

function addNewTask(taskText) {
    // Parse the task text for natural language elements
    const task = parseNaturalLanguage(taskText);
    
    // Create new task element
    const taskElement = createTaskElement(task);
    
    // Add to task list with animation
    const tasksList = document.querySelector('.tasks');
    taskElement.style.opacity = '0';
    taskElement.style.transform = 'translateY(-20px)';
    tasksList.insertBefore(taskElement, tasksList.firstChild);
    
    // Animate in
    setTimeout(() => {
        taskElement.style.transition = 'all 0.3s ease';
        taskElement.style.opacity = '1';
        taskElement.style.transform = 'translateY(0)';
    }, 10);
    
    // Update task count
    updateTaskCount();
    
    // Show success feedback
    showSuccessFeedback('Task created successfully!');
}

function parseNaturalLanguage(text) {
    const task = {
        title: text,
        priority: 'medium',
        dueDate: null,
        tags: [],
        project: null
    };
    
    // Extract priority
    if (text.toLowerCase().includes('urgent')) {
        task.priority = 'urgent';
        task.title = task.title.replace(/\burgent\b/gi, '').trim();
    } else if (text.toLowerCase().includes('high priority')) {
        task.priority = 'high';
        task.title = task.title.replace(/\bhigh priority\b/gi, '').trim();
    } else if (text.toLowerCase().includes('low priority')) {
        task.priority = 'low';
        task.title = task.title.replace(/\blow priority\b/gi, '').trim();
    }
    
    // Extract due date
    if (text.toLowerCase().includes('today')) {
        task.dueDate = 'today';
        task.title = task.title.replace(/\btoday\b/gi, '').trim();
    } else if (text.toLowerCase().includes('tomorrow')) {
        task.dueDate = 'tomorrow';
        task.title = task.title.replace(/\btomorrow\b/gi, '').trim();
    }
    
    // Extract tags
    const tagMatches = text.match(/#\w+/g);
    if (tagMatches) {
        task.tags = tagMatches.map(tag => tag.substring(1));
        task.title = task.title.replace(/#\w+/g, '').trim();
    }
    
    // Extract project
    const projectMatch = text.match(/@\w+/);
    if (projectMatch) {
        task.project = projectMatch[0].substring(1);
        task.title = task.title.replace(/@\w+/g, '').trim();
    }
    
    // Clean up title
    task.title = task.title.replace(/\s+/g, ' ').trim();
    
    return task;
}

function createTaskElement(task) {
    const taskElement = document.createElement('div');
    taskElement.className = `task-item ${task.priority}`;
    
    const priorityColors = {
        urgent: 'urgent',
        high: 'high',
        medium: 'medium',
        low: 'low'
    };
    
    const dueDateClass = task.dueDate === 'today' ? 'today' : 
                        task.dueDate === 'tomorrow' ? 'tomorrow' : '';
    
    taskElement.innerHTML = `
        <div class="task-checkbox"></div>
        <div class="task-priority ${priorityColors[task.priority]}"></div>
        <div class="task-content">
            <div class="task-title">${task.title}</div>
            ${task.tags.length > 0 ? `
                <div class="task-meta">
                    ${task.tags.map(tag => `<span class="tag">#${tag}</span>`).join('')}
                    ${task.project ? `<span class="project">@${task.project}</span>` : ''}
                </div>
            ` : ''}
        </div>
        ${task.dueDate ? `<div class="task-due ${dueDateClass}">${task.dueDate}</div>` : ''}
    `;
    
    // Add click handler
    taskElement.addEventListener('click', function() {
        showDetail();
    });
    
    // Add checkbox handler
    const checkbox = taskElement.querySelector('.task-checkbox');
    checkbox.addEventListener('click', function(e) {
        e.stopPropagation();
        toggleTaskCompletion(this);
    });
    
    return taskElement;
}

// Utility Functions
function updateTaskList(filterType) {
    const tasks = document.querySelectorAll('.task-item');
    
    tasks.forEach(task => {
        let shouldShow = true;
        
        switch (filterType.toLowerCase()) {
            case 'today':
                shouldShow = task.querySelector('.task-due.today') !== null;
                break;
            case 'overdue':
                shouldShow = task.querySelector('.task-due.overdue') !== null;
                break;
            case 'completed':
                shouldShow = task.classList.contains('completed');
                break;
            case 'upcoming':
                shouldShow = task.querySelector('.task-due') !== null && 
                           !task.querySelector('.task-due.today') && 
                           !task.querySelector('.task-due.overdue');
                break;
            default:
                shouldShow = true;
        }
        
        task.style.display = shouldShow ? 'flex' : 'none';
    });
    
    updateTaskCount();
}

function updateTaskCount() {
    const visibleTasks = document.querySelectorAll('.task-item[style*="display: flex"], .task-item:not([style*="display: none"])');
    const taskCount = document.querySelector('.task-count');
    const count = visibleTasks.length;
    taskCount.textContent = `${count} ${count === 1 ? 'task' : 'tasks'}`;
}

function showDetail() {
    const taskDetail = document.getElementById('taskDetail');
    const taskList = document.querySelector('.task-list');
    
    taskDetail.style.display = 'block';
    taskList.style.flex = '1';
    
    // Add slide-in animation
    taskDetail.style.transform = 'translateX(100%)';
    setTimeout(() => {
        taskDetail.style.transition = 'transform 0.3s ease';
        taskDetail.style.transform = 'translateX(0)';
    }, 10);
}

function closeDetail() {
    const taskDetail = document.getElementById('taskDetail');
    const taskList = document.querySelector('.task-list');
    
    taskDetail.style.transform = 'translateX(100%)';
    setTimeout(() => {
        taskDetail.style.display = 'none';
        taskList.style.flex = '1';
        taskDetail.style.transition = '';
    }, 300);
}

function showCompletionAnimation(taskElement) {
    // Add completion effect
    taskElement.style.transform = 'scale(1.02)';
    setTimeout(() => {
        taskElement.style.transform = '';
    }, 200);
    
    // Show checkmark animation
    const checkbox = taskElement.querySelector('.task-checkbox');
    checkbox.style.transform = 'scale(1.2)';
    setTimeout(() => {
        checkbox.style.transform = '';
    }, 200);
}

function showViewChangeAnimation() {
    const taskList = document.querySelector('.task-list');
    taskList.style.opacity = '0.5';
    setTimeout(() => {
        taskList.style.opacity = '1';
    }, 200);
}

function showSuccessFeedback(message) {
    // Create feedback element
    const feedback = document.createElement('div');
    feedback.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: var(--primary-green);
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 500;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 1000;
        transform: translateX(100%);
        transition: transform 0.3s ease;
    `;
    feedback.textContent = message;
    
    document.body.appendChild(feedback);
    
    // Animate in
    setTimeout(() => {
        feedback.style.transform = 'translateX(0)';
    }, 10);
    
    // Remove after delay
    setTimeout(() => {
        feedback.style.transform = 'translateX(100%)';
        setTimeout(() => {
            document.body.removeChild(feedback);
        }, 300);
    }, 3000);
}

// Search functionality
function setupSearch() {
    const searchInput = document.querySelector('.search-field input');
    
    searchInput.addEventListener('input', function() {
        const query = this.value.toLowerCase();
        const tasks = document.querySelectorAll('.task-item');
        
        tasks.forEach(task => {
            const title = task.querySelector('.task-title').textContent.toLowerCase();
            const description = task.querySelector('.task-description')?.textContent.toLowerCase() || '';
            const tags = Array.from(task.querySelectorAll('.tag')).map(tag => tag.textContent.toLowerCase()).join(' ');
            
            const matches = title.includes(query) || description.includes(query) || tags.includes(query);
            task.style.display = matches ? 'flex' : 'none';
        });
        
        updateTaskCount();
    });
}

// Initialize search after DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    setupSearch();
});

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    // Cmd/Ctrl + N: Focus quick entry
    if ((e.metaKey || e.ctrlKey) && e.key === 'n') {
        e.preventDefault();
        document.querySelector('.quick-entry input').focus();
    }
    
    // Cmd/Ctrl + F: Focus search
    if ((e.metaKey || e.ctrlKey) && e.key === 'f') {
        e.preventDefault();
        document.querySelector('.search-field input').focus();
    }
    
    // Escape: Close detail view
    if (e.key === 'Escape') {
        const taskDetail = document.getElementById('taskDetail');
        if (taskDetail.style.display === 'block') {
            closeDetail();
        }
    }
});

// Add some demo interactions
setTimeout(() => {
    // Simulate a notification
    if (Math.random() > 0.7) {
        showSuccessFeedback('Welcome to TaskManager Demo!');
    }
}, 2000);