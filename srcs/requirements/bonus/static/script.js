const input = document.getElementById("command");
const output = document.getElementById("output");

input.addEventListener("keydown", function(event) {
    if (event.key !== "Enter")
        return;

    const command = input.value.trim().toLowerCase();

    output.innerHTML += `<p><span class="prompt">reda@portfolio:~$</span> ${command}</p>`;

    if (command === "help") {
        output.innerHTML += `
            <p>Available commands:</p>
            <p>whoami &nbsp;&nbsp;&nbsp; - About me</p>
            <p>portfolio &nbsp; - My projects</p>
            <p>skills &nbsp;&nbsp;&nbsp;&nbsp; - My skills</p>
            <p>contact &nbsp;&nbsp;&nbsp; - Contact me</p>
            <p>clear &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - Clear terminal</p>
        `;
    }
    else if (command === "whoami") {
        output.innerHTML += `
            <p>Hi, I'm Reda Tahri, 24 years old.</p>
            <p>I'm a dedicated student at the 42 Network,</p>
            <p>where I thrive in a collaborative and innovative learning environment.</p>
        `;
    }
    else if (command === "portfolio") {
        output.innerHTML += `
            <p><strong>minishell</strong> - Unix shell, processes, pipes and redirections.</p>
            <p><strong>philosophers</strong> - Threads, mutexes and synchronization.</p>
            <p><strong>cub3d</strong> - 3D raycasting engine using MiniLibX.</p>
            <p><strong>netpractice</strong> - IP addresses, subnetting and routing.</p>
        `;
    }
    else if (command === "skills") {
        output.innerHTML += `
            <p>C / C++</p>
            <p>Linux / Bash</p>
            <p>Git / GitHub</p>
            <p>Docker</p>
            <p>Networking</p>
            <p>HTML / CSS / JavaScript</p>
            <p>PHP / WordPress</p>
        `;
    }
    else if (command === "contact") {
        output.innerHTML += `
            <p>Email: retahri@42.fr</p>
            <p>GitHub: goldinooo</p>
            <p>LinkedIn: coming soon</p>
        `;
    }
    else if (command === "clear") {
        output.innerHTML = "";
    }
    else if (command !== "") {
        output.innerHTML += `<p>Command not found: ${command}</p>`;
        output.innerHTML += `<p>Type <strong>help</strong> for available commands.</p>`;
    }

    input.value = "";
}); 