# physics-based-circle-packing
Exploration of circle packing using a physics simulation of repelling particles. (For the loosest definition of all of those words). 

Here is a link to the p5.js implementation fo this idea: https://r4chel.github.io/physics-based-circle-packing/

I will be implementing the algorithm in a few languages.

# Inspiration and sources 

http://www.codeplastic.com/2017/09/09/controlled-circle-packing-with-processing/

^^^^^ That blog post is the initial inspiration for this project <3 

Also using knowledge previously learned from [Coding Train](https://thecodingtrain.com) including [Challenge 50: Circle Packing](https://www.youtube.com/watch?v=QHEQuoIKgNE&t=4s)


# Current status and thoughts
I spent a weekend working on this and it was a lot of fun. The idea evolved over the course of the weekend and here is a bit about that.

## Initial idea
As mentioned above, the blog post by Alberto Giachino was the direct inspiration for the start of the project. Here's that idea:

Circle packing is often done in an additive where where you add shapes in fixed points. This can be done by randomly sampling of points and seeing how large a shape there can be without overlapping or by choosing some starting points and letting them grow until they overlap. 

Alberto Giachino's blog post suggested an alternative approach. Put a bunch of circles in a space and "let them fight it out". Or as he put it more precisely "the circles will try to find by themselves their optimal/sub-optimal position by moving inside the given space".

## Where did I go from there
Alberto's blog has processing code that I started translating to p5.js. But I am not super comfortable with using code I don't understand and I had some questions about some of it and why it had the desired effect. Also towards my artistic approach, even though I really like the output shown, I am usually a lot more interested in exploring how to get there than just to create the output shown. (Also that's often where interesting things happen and what I make diverges from any inspiration.)


So my plan was to write the code in p5.js, then python and elm. The reason for those specific languages is that p5.js is pretty much always my go to for ideation and exploration. I find it to be the easiest to explore and test out ideas. So when I'm trying a new idea, even if I think I know exactly how it will look I often write it p5.js first and then move it another language if there is a reason I want it in another language. 

The motivation for Elm, is this week I am playing with Elm and trying dust off some cobwebs. Also I've enjoyed the past few days writing Elm after writing a looot of p5.js and thinking about creating art in a different paradigm. Also I personally love translating a piece of art from one language to another because what is "easy/free" in each language influences the final output.

The motivation for python was, that is what I am using for penplotting thanks to @abey79's library vsketch. Although I had a supsicious I would be able to output svgs my penplotter could draw from Elm without python so this was the lowest priority and has not yet happened. 

### p5 implementation
In trying to understand Alberto's implementation and write it while making sure I understood it I had a few observations.

This is not precisely what is happening but here is the model I developed

#### A Slightly Different Model
What if put a bunch of positviley charged particles in a simulation? Could we get them to find the optimal placement by being repelled from eachother. 

##### Differences 
That sounds a lot like what was being done so what is the actual difference. 

- Which circles act on which other circles. In a physics simulation all particles exhert force on all other particles not just the ones that they overlap with as was done in the initial implementation. 
- Particles have momentum. In Alberto's model, once a circle does not overlap with anyother circle it stops moving. 
- Acceleration is inversely proportional to mass. Rember our friend `F = ma` What a classic! In the original model "mass" is not taken into account. 


That last one is really what motivated me to try something different. 

### A nice animation 
When I make an animation I often find it suprising when larger objects are moving faster than smaller objects, all other things being equal. Now, I do not take this as a hard and fast rule that animations must match our lived experiences with physics, just I like to be deliberate about when I am choosing to change or ignore real world phsyics. I'm sure there is some psychology stuff going on here that I don't really know and like I super strongly encourage everyone to make physics defying animations. 1. It's a whole lot easier 2. Don't let you're imagination for what you want to make digitally be limited by what could or couldn't exist. 


Ok preaching over. 

I didn't take my advice and decided to explore this. 


# Takeaways 

## Physics is hard
I am pretty sure my elm implementation has some bugs. I may in the future debug what I did and explore more. But here is part of the struggle. 

Statement: The model is not behaving how I want it to.

Potential Causes:
1. I made a mistake in modeling. Physics is hard it is super likely that I did not encode what I intended to correctly,
2. Choosing constants is hard. Seriously props to Coulomb, and Planck, and Avogadro. Choosing constants is really hard they did a great job. 
   
### Constant struggle
My model is not a model of actual particles. I am making a simlulation inspired by physics but not following real world physics. I get to choose how dense these shapes are (aka what is the relation ship between radius and mass). I get to choose my equivalent of Coulomb's constant. 

When the simulation is behaving suprisingly is it becasue, the simluation is buggy or these constants won't give the desired outcome. 

#### Solution
I didn't realllly solve this problem. I put a gui in the p5 impelentation with sliders for each of thses values and impericle chose numbers I like. Then when I went to elm, I ran into new problems so don't feel the most satisfying. 


## This blog post is a stream concious out of order
I just realized I started writing take aways up there a bit and then went into more detail. Cool I got some more take aways and I'm going to keep going with the stream of concious dump. Sorry if you were looking for a polished blog post.

# Edge Cases 
There was some logic I had taken from Alberto's code about how to handle edges. It's a fun thing to think about and I've played with a number of different approaches in the past. Here are few options of what to when a shape is going to be outside the canvas.
0. Do nothing. Let shapes get lost and leave the canvas. Maybe they'll find their way home later, maybe they'll make a life for themselves outside of what we can see. I don't personally recommend this as a long term approach but still thought it was worth mentioning. 
1. Clamp it. Force the position to always be between (0,{width/height}) by setting the position to the extreme if it would otherwise go outside.
2. Modulo. If you want to always have a number betwen two other other numbers modulus is a great way to get his. (Heads up there are some quirks in javascript so be careful if using this in p5.js). This approach has topology of a sphere.
2b. Same idea but non-spherical geometry. You could have a mobius strip or klien bottle or something else all together. 
3. Remove the shape. If you can't stay in the bounds, you don't get to be in the pretty picture. Personally I've never used this approach and it never occurred to me until writing up this list. 
4. Move the shape to a random spot inside. Again, this is in the do something that is easy to code and move on category for me personally. 
5. Bounce! Wow I started writing this list thinking it was going to be clamp, mod, or bounce but I had a bunch of other ideas before I got to bounce. Ok so bounce is the path would have gone outside the box but there is a wall in its way so reflect the path. This can be done by inverting velocity, which is how Alberto's code did it. 
   Some fun things to think about for bounce are, should the magnitude of velocity stay the same. You can pretty easily model some different surfaces by multiplying the velocity by a scalar. Less than 1, the object will slow down, greater than 1 the edges will appear rubbery. Darn it I've pretty hard on physics in this post, but like physics is pretty fun! 
   
   
### Runaway shapes
I ran into a problem where I had set for there to be 100 initial shapes but looking at the simluation it looked a lot more like about 30 to me. I checked the dev tools and there were in fact 100 shapes still but many of them were far away from the canvas. Now I had not gone with the "Do nothing approach" so this was suprising. 
#### What happened 
Here's what happened. If the object was outside the box I would multiply velocity by -1 in the dimension(s) for which it was outside. Well this assumes the shapes are moving in the direction that would get them further away. Some of the shapes had moved with such force outside the box initially that I was now just pushing them further and further away. Additionally, I didn't mention this but many of the shapes outside the box had no other shapes overlapping with them so there velocity was tending towards 0 and multiplying 0 by -1 any number of times wasn't going to move it anywhere.

# Some other things I thought about but didn't really explore
## Optimization. 
Doing the caluclation of the force on each pair of paricles may have some scaling problems. I spent some time thinking about this and some ideas for how to make some perforamance improvements, but recognized I wanted to get something working even if it was slow before I worried about how to speed it up. I didn't quite getting to "working" so I didn't get around to performance imporements. Although if I do decide to explore that, I came across this paper although I did not yet read it. 

[A Continuum,O(N) Monte-Carlo algorithm for charged particles](https://arxiv.org/abs/cond-mat/0308441)

Also here's another paper that got added to my to read while googling things related to this project.
- [A linearized circle packing algorithm](https://www.sciencedirect.com/science/article/pii/S0925772117300172)

# Final Thoughts
As of this morning, my thoughts are that was a fun weekend project. I learned some stuff. I made "physics" simulation. It was challenging in ways I didn't expect. I still really like Alberto's original post and images created. I didn't plot anything on the penplotter. 

I still really want to play with the idea of perlin noise x circle packing. I think the output was beautiful nd those are two of my favorite generative art tools. However, I am pausing this project for now. 
https://r4chel.github.io/physics-based-circle-packing/
Enjoy the p5.js version and feel free to clone and explore the elm impelentation.





