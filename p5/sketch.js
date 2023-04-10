let shapes;
let colors;

const maxRadiusRatio = 15;
const minRadiusRatio = 1000;
let minRadius, maxRadius;
const initialShapes = 125;
var density = 1
var forceConstant = 0.05
var drag = 0.9
var forceConstantStep = 0.005
var forceConstantMax = 0.5
var dragStep = 0.05
var dragMax = 1.05
var densityMin = 0.05
var densityStep = 0.05
var maxForce = 50000


function MyShape({
    x,
    y,
    r
}) {
    this.p = createVector(x, y);
    this.velocity = p5.Vector.random2D();
    this.color = color(random(colors));
    this.color.setAlpha(200);
    this.r = 2 + lerp(minRadius, maxRadius, noise(this.p.x * 0.01, this.p.y * 0.01));
    this.force = createVector(0, 0);
    this.neighbors = 0;

    this.updateRadius = function() {
        this.r = 2 + lerp(minRadius, maxRadius, noise(this.p.x * 0.01, this.p.y * 0.01));
    }

    this.mass = function() {
        return this.r * this.r * density
    };

    this.draw = function() {
        fill(this.color);
        circle(this.p.x, this.p.y, this.r);
    };

    this.update = function() {
        if (this.neighbors == 0 || this.velocity > this.maxVelocity) {

            this.velocity.mult(drag);
        }
        this.force.limit(maxForce)
        this.force.div(this.mass());
        this.velocity.add(this.force);
        this.p.add(this.velocity);
        this.force.set(0, 0);
        this.neighbors = 0;
    };

    this.checkBorders = function() {
        if (this.p.x - this.r < 0 || this.p.x + this.r > width) {
            this.velocity.x *= -1;
            this.p.add(this.velocity);
        }
        if (this.p.y - this.r < 0 || this.p.y + this.r > height) {
            this.velocity.y *= -1;
            this.p.add(this.velocity);
        }

        // shapes were getting trapped on the outside. This is a ..... fix
        if (this.p.x < 0 || this.p.x > width || this.p.y < 0 || this.p.y > height) {
            this.p.set(random(width), random(height));
        }

    };
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
        r: random(minRadius, maxRadius)
    }));
}

function calculatePairwiseForce(s1, s2) {
    let d = p5.Vector.dist(s1.p, s2.p);
    // if shapes don't touch, they don't exert a force on eachother
    if (d > s1.r + s2.r) {
        return null;
    }
    // avoiding division by 0 issue (although not sure what number to be here)
    if (d == 0) {
        d = .01;
    }
    // direction is based on difference
    let diff = p5.Vector.sub(s1.p, s2.p);
    diff.normalize();

    // force is inversely proportional to distance between shapes 
    diff.div(d * d);

    diff.mult(forceConstant * s1.mass() * s2.mass());
    return diff;

}

function calculateForce(shapes, i) {
    let shape = shapes[i];
    for (let j = i + 1; j < shapes.length; j++) {
        let other = shapes[j];
        let force = calculatePairwiseForce(shape, other);
        if (force === null) {
            continue;
        }
        shape.force.add(force);
        other.force.sub(force);
        shape.neighbors += 1;
        other.neighbors += 1;
    }
}

function draw() {
    background(240);

    let maximumForce = 0;

    // update radius' before doing anthing else because radius effects force 
    for (let i = 0; i < shapes.length; i++) {
        let s = shapes[i];
        s.updateRadius();
    }
    for (let i = 0; i < shapes.length; i++) {
        let s = shapes[i];
        s.updateRadius();
        s.checkBorders();
        calculateForce(shapes, i);
        maximumForce = max(s.force.mag(), maximumForce)
        s.update();
        s.draw();
    }

    if (maximumForce == 0) {
        shapes.push(new MyShape({
            x: random(width),
            y: random(height),
            r: random(minRadius, maxRadius)
        }))
    }


}