let shapes;
let colors;

const maxRadiusRatio = 15;
const minRadiusRatio = 500;
let minRadius, maxRadius;
const initialShapes = 100;
const density = .1

function MyShape({
    x,
    y,
    r
}) {
    this.p = createVector(x, y);
    this.velocity = p5.Vector.random2D();
    this.color = random(colors);
    this.r = r;
    this.force = createVector(0, 0);
    this.neighbors = 0;


    this.mass = function() {
        return this.r * this.r * density
    }
    this.draw = function() {
        fill(this.color);
        circle(this.p.x, this.p.y, this.r);
    };

    this.update = function() {
        if (this.neighbors > 0) {
            this.force.div(this.neighbors * this.mass());
        } else {
            if (this.force.mag() != 0) {
                print("huh")
            }
        }
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
        x: width / 2,
        y: height / 2,
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
        d = 1;
    }
    // direction is based on difference
    let diff = p5.Vector.sub(s1.p, s2.p);
    diff.normalize();

    // force is inversely proportional to distance between shapes 
    diff.div(d);
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
        shape.force.add(force * other.mass());
        other.force.sub(force * shape.mass());
        shape.neighbors += 1;
        other.neighbors += 1;
    }
}

function draw() {
    background(240);

    for (let i = 0; i < shapes.length; i++) {
        let s = shapes[i];
        s.draw();
        s.checkBorders();
        calculateForce(shapes, i);
        s.update();
    }



}