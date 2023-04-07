let shapes;
let colors;

const maxRadiusRatio = 5;
const minRadiusRatio = 500;
let minRadius, maxRadius;
const initialShapes = 100;

function MyShape({
    x,
    y,
    r
}) {
    this.p = createVector(x, y)
    this.acceleration = createVector(0, 0)
    this.velocity = p5.Vector.random2D();
    this.color = random(colors)
    this.r = r

    this.draw = function() {
        fill(this.color);
        circle(this.p.x, this.p.y, this.r);
    };

    this.update = function() {
        this.acceleration.add(random(-0.01, 0.01), random(-0.01, 0.01))
        this.velocity.add(this.acceleration)
        this.p.add(this.velocity)
    }

}

function setup() {
    createCanvas(windowWidth, windowHeight);

    minRadius = min(width, height) / minRadiusRatio;
    maxRadius = max(width, height) / maxRadiusRatio;
    ellipseMode(RADIUS);

    colorMode(RGB, 255);
    colors = [color(236, 232, 125), color(52, 115, 76), color(83, 176, 193)];

    noStroke();
    shapes = [...new Array(initialShapes)].map(() => new MyShape({
        x: random(width),
        y: random(height),
        r: 20
    }));
}

function maxSize(x, y) {
    let m = maxRadius;
    for (let i = 0; i < circles.length; i++) {
        let c = circles[i];
        let distance = dist(x, y, c.x, c.y);
        m = min([distance - c.r / 2, m]);
    }
    return m;
}

function draw() {
    background(240);

    for (let i = 0; i < shapes.length; i++) {
        let s = shapes[i];
        s.draw();
        s.update();
    }


}