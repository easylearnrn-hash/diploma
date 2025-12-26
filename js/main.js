// Main JavaScript file for Diploma Project

// Login form handler
document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    
    if (loginForm) {
        loginForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            
            // Basic validation
            if (email && password) {
                // Simulate login validation
                // In production, this would be an API call to your backend
                console.log('Login attempt:', { email, password });
                
                // Redirect to student portal on successful login
                window.location.href = 'Student-page.html';
            } else {
                alert('Please enter both email and password');
            }
        });
    }
});

// Add more JavaScript functionality as needed
console.log('Diploma Project initialized');
