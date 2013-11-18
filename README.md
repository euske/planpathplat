Path Planning (AI) in Platformer Games
======================================

I've been working on path planning for platformer games for a
while. My original intention was to create a "scripted" character in a
platformer game more easily, but it can have other interesting
applications. I have a working prototype and its source code.


Handling Continuous Space
-------------------------

The first problem that we need to address is the continuous nature of
a platformer game. In a typical path planning, a problem is usually
represpented as a discrete space. However, in a platformer game where
characters often are affected by gravity, handling its continuous
movement is crucial. We addressed this issue by dividing the problem
into two layers: macro-level planning and micro-level planning. The
macro-level planning takes care of a coarse-grained plan such as "go
to this block" or "jump here and try to land at that block". The
micro-level planning takes care of more fine-tuned movement that
involves a continuous 2-D space. The macro-level planning is done by
using typical AI techniques per block basis, constructing a mesh of
possible action at each place. The micro-level planning is done in a
more greedy manner, by taking care of physical collisions and
character coordinates.

The macro-level planning can be implemented with a pretty
straightforward Dijkstra or A* search. It starts from the goal 
position, and iteratively searches all possible movements
until it reaches the start (the position of the character).
The planning graph is created and extended on block basis, 
and additional restrictions (e.g. space constraints and ladders)
are considered.


Jumping / Falling
-----------------

Jumping and falling is the key element of platformer games and the
core of its planning problem. It has so many parameters that using
naive methods will easily lead to computational explosion. In the
proposed method, the macro-level planner only takes care of its
starting point and ending point in the block coordinates. The planner
has to know in advance the speed of the character in question and its
jump impulse, as well as the gravity acceleration, so that it can know
where it will exactly land. The macro-level planner doesn't take care
of an actual trajectory of characters.


Landing Prediction
------------------

Splinting / Double Jumping
--------------------------

Moving Platforms
----------------

A-star or not A-star?
---------------------

Source Code Structure
---------------------

There are several important classes that do the logic.
They are mostly separated from the UI.

 * Actor
 * PlanAction
 * PlanMap
 * TileMap

Is This Smarter than humans?
----------------------------

Unfortunately, no.  Due to computational limits, the current
implementation considers only a handful of ways of possible jumps at
each position. Since it uses a rectangle as an approximation of jump
trajectory, it cannot emulate a complex manuever that humans could
do. Also, since it's on block-by-block basis, it cannot consider a
possibility of barely-make-it kinds of jumps. These are mostly
complexity problems, but in some cases there might be need to give up
to find an optimal solution.

