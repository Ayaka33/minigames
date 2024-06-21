let canvas = document.getElementById("canvas");
let ctx = canvas.getContext("2d");

let W = canvas.width;
let H = canvas.height;
let degrees = 0;
let new_degrees = 0;
let time = 0;
let color = "#ff0000";
let txtcolor = "#ffffff";
let bgcolor = "#404b58";
let successColor = "#00ff00";
let normalZoneColor = "#41a491";
let targetKey;
let g_start, g_end;
let animation_loop;

let streak = 0;
let maxStreak = 0;

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min);
}

function drawArc(color, lineWidth, radius, startAngle, endAngle) {
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth = lineWidth;
    ctx.arc(W / 2, H / 2, radius, startAngle, endAngle, false);
    ctx.stroke();
}

function drawNeedle() {
    let radians = degrees * Math.PI / 180;
    drawArc(color, 40, 90, radians - 0.1 - Math.PI / 2, radians - Math.PI / 2);
}

function draw() {
    if (animation_loop !== undefined) clearInterval(animation_loop);

    document.querySelector('.streak').textContent = streak;
    document.querySelector('.max-streak').textContent = maxStreak;

    g_start = getRandomInt(20, 40) / 10;
    g_end = g_start + getRandomInt(3, 5) / 10;

    degrees = 0;
    new_degrees = 360;

    targetKey = '' + getRandomInt(1, 4);

    time = getRandomInt(1, 3) * 6;

    animation_loop = setInterval(animateTo, time);
}

function animateTo() {
    if (degrees >= new_degrees) {
        updateStatus('Skipped!');
        processFailure();
        draw();
        return;
    }

    degrees += 2;
    initCanvas();
}

function initCanvas(correct = false) {
    ctx.clearRect(0, 0, W, H);
    drawArc(bgcolor, 20, 100, 0, Math.PI * 2);
    drawArc(correct ? successColor : normalZoneColor, 20, 100, g_start - Math.PI / 2, g_end - Math.PI / 2);
    drawNeedle();
    drawKey();
}

function drawKey() {
    ctx.fillStyle = txtcolor;
    ctx.font = "100px sans-serif";
    let textWidth = ctx.measureText(targetKey).width;
    ctx.fillText(targetKey, W / 2 - textWidth / 2, H / 2 + 35);
}

function updateStatus(message) {
    document.querySelector('.status').textContent = message;
}

function processSuccess() {
    streak++;
    if (streak > maxStreak) {
        maxStreak = streak;
    }
    document.querySelector('.stats').classList.remove('wrong');
}

function processFailure() {
    if (streak > maxStreak) {
        maxStreak = streak;
    }
    streak = 0;
    document.querySelector('.stats').classList.add('wrong');
}

document.addEventListener("keydown", function (ev) {
    let keyPressed = ev.key;
    let validKeys = ['1', '2', '3', '4'];

    if (validKeys.includes(keyPressed)) {
        successColor = "#ff0000";
        if (keyPressed === targetKey) {
            let d_start = (180 / Math.PI) * g_start;
            let d_end = (180 / Math.PI) * g_end;
            if (degrees < d_start) {
                updateStatus('Too soon!');
                processFailure();
            } else if (degrees > d_end) {
                updateStatus('Too late!');
                processFailure();
            } else {
                updateStatus('Success!');
                successColor = "#00ff00";
                processSuccess();
            }
        } else {
            updateStatus('Failed: Pressed ' + keyPressed);
            processFailure();
        }
        initCanvas(true);
        clearInterval(animation_loop);
        setTimeout(function() {
            draw();
        }, 1000); // Delay for 1 second
    }
});

draw();
