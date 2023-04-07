let circles = [];
let colors;

const maxRadiusRatio = 5;
const minRadiusRatio = 500;
let minRadius, maxRadius;

function setup() {
    createCanvas(windowWidth, windowHeight);

    minRadius = min(width, height) / minRadiusRatio;
    maxRadius = max(width, height) / maxRadiusRatio;

    colorMode(RGB, 255);
    colors = [color(236, 232, 125), color(52, 115, 76), color(83, 176, 193)];

    noStroke();
}

function spawnCircle() {
    let x = random(width);
    let y = random(height);
    let r = maxSize(x, y) * random(0.25, 0.95);
    if (r > minRadius) {
        circles.push({
            x: x,
            y: y,
            r: r,
            color: random(colors)
        });
    }
}

function maxSize(x, y) {
    let m = maxRadius;
    for (let i = 0; i < circles.length; i++) {
        let c = circles[i];
        let distance = dist(x, y, c.x, c.y);
        m = min([distance - c.r / 2, m]);
    }
    return m * 2;
}

function draw() {
    background(240);

    for (let i = 0; i < circles.length; i++) {
        let c = circles[i];
        fill(c.color);
        circle(c.x, c.y, c.r);
    }

    spawnCircle();
}