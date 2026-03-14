// Space facts database
const spaceFacts = [
    "One million Earths could fit inside the Sun!",
    "There are more stars in space than grains of sand on Earth.",
    "A day on Venus is longer than a year on Venus.",
    "Neutron stars can spin up to 600 times per second.",
    "The largest asteroid in our solar system is Ceres.",
    "Jupiter's Great Red Spot has been raging for over 350 years.",
    "Footprints on the Moon will stay there for millions of years.",
    "Saturn's rings are made of ice and rock.",
    "The Sun loses up to 1 billion kg per second due to solar wind.",
    "There's a giant water vapor cloud in space holding 140 trillion times Earth's water.",
    "A year on Mercury is just 88 Earth days long.",
    "Mars has the largest volcano in the solar system - Olympus Mons.",
    "Uranus spins on its side like a rolling ball.",
    "Pluto is smaller than the United States.",
    "The coldest place in the universe is on Earth (in laboratories)!"
];

// Planet-specific facts
const planetFacts = {
    mercury: "Mercury has no atmosphere, which means there's no wind or weather!",
    venus: "Venus is the hottest planet at 475°C - hot enough to melt lead!",
    earth: "Earth is the only planet not named after a Roman god or goddess.",
    mars: "Mars has the largest dust storms in the solar system, lasting months!",
    jupiter: "Jupiter's magnetic field is 20,000 times stronger than Earth's.",
    saturn: "Saturn is so light it would float in water - if you could find a bathtub big enough!"
};

// Function to show random space fact
function showRandomFact() {
    const factElement = document.getElementById('space-fact');
    const randomIndex = Math.floor(Math.random() * spaceFacts.length);
    factElement.textContent = "✨ " + spaceFacts[randomIndex] + " ✨";
    factElement.style.animation = "glow 1s ease";
    setTimeout(() => {
        factElement.style.animation = "";
    }, 1000);
}

// Function to explore planets
function explorePlanet(planet) {
    const factElement = document.getElementById('space-fact');
    if (planetFacts[planet]) {
        factElement.textContent = "🪐 " + planetFacts[planet] + " 🪐";
        factElement.style.background = "rgba(78, 205, 196, 0.3)";
        
        // Highlight selected planet
        const cards = document.querySelectorAll('.planet-card');
        cards.forEach(card => {
            card.style.transform = "scale(1)";
            card.style.boxShadow = "none";
        });
        
        event.currentTarget.style.transform = "scale(1.1)";
        event.currentTarget.style.boxShadow = "0 0 30px #4ecdc4";
    } else {
        showRandomFact();
    }
}

// Function to set deployment info
function setDeploymentInfo() {
    // Set deployment date
    const now = new Date();
    const deploymentDate = document.getElementById('deployment-date');
    deploymentDate.textContent = now.toLocaleDateString() + ' at ' + now.toLocaleTimeString();
    
    // Generate unique mission ID
    const missionId = document.getElementById('mission-id');
    const id = 'MISSION-' + Math.random().toString(36).substr(2, 9).toUpperCase();
    missionId.textContent = id;
    
    // Add to console for fun
    console.log('%c🚀 Space Website Deployed on Azure!', 'color: #4ecdc4; font-size: 16px;');
    console.log('Mission ID:', id);
    console.log('Deployment Time:', now.toLocaleString());
}

// Function to create shooting stars
function createShootingStar() {
    const star = document.createElement('div');
    star.style.position = 'fixed';
    star.style.width = '100px';
    star.style.height = '2px';
    star.style.background = 'linear-gradient(90deg, transparent, white, transparent)';
    star.style.left = Math.random() * window.innerWidth + 'px';
    star.style.top = '0px';
    star.style.animation = 'shoot 1s linear';
    star.style.zIndex = '1000';
    
    document.body.appendChild(star);
    
    setTimeout(() => {
        star.remove();
    }, 1000);
}

// Add shooting star animation
const style = document.createElement('style');
style.textContent = `
    @keyframes shoot {
        0% { transform: translateY(0) rotate(45deg); opacity: 1; }
        100% { transform: translateY(500px) rotate(45deg); opacity: 0; }
    }
`;
document.head.appendChild(style);

// Initialize everything when page loads
window.onload = function() {
    setDeploymentInfo();
    showRandomFact();
    
    // Show random fact every 30 seconds
    setInterval(showRandomFact, 30000);
    
    // Create occasional shooting star
    setInterval(createShootingStar, 5000);
    
    // Add click event to all planet cards
    document.querySelectorAll('.planet-card').forEach(card => {
        card.addEventListener('click', function(e) {
            const planet = this.querySelector('h3').textContent.toLowerCase();
            explorePlanet(planet);
        });
    });
};

// Add some interactive mouse movement effect
document.addEventListener('mousemove', function(e) {
    const stars = document.querySelector('.stars');
    if (stars) {
        const x = e.clientX / window.innerWidth;
        const y = e.clientY / window.innerHeight;
        stars.style.transform = `translate(${x * 20}px, ${y * 20}px)`;
    }
});

// Handle errors gracefully
window.onerror = function(msg, url, line) {
    console.log('Space communication stable. Error logged to mission control.');
    return true;
};