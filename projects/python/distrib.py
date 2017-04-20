

# Just do this:

# put a point in a rectangular box, 600 x 400, at a location.

# Create an object Wall to represent each wall.

# repeatedly:
#   get vector from each wall to self.
#   reverse each vector (so that it is a vector from self to the wall)
#   add all vectors, which should leave the vector away from all walls.
#   normalize the vector, then scale it to max dist to move per turn.
#   move to the new location.


# Need to rethink this algorithm: only works when you have walls on opposite
# sides of a person, not repelling persons from each other...

# Think about all objects around you as exerting a force on you away from themselves.
# So, wall to your west is pushing you east, wall to your east is pushing you west, person
# to your southeast is pushing you northwest.
# but, the closer the other object, the bigger the force.  The question is how to do this
# conversion -- smaller vector --> bigger vector and vice versa.
# If we subtract from a constant, then negative vectors get even bigger negative...
# Seems like we should multiply by something.... to keep the signs the same...  but what?

# But, what number?  1 over the average magnitude?  1 over the max magnitude?

# Suppose we are at 200, 200 in a 600 x 400 world (just west of center at 300, 200).  Then,
# the vector from walls are:
# west: (200, 0)
# east: (-400, 0)
# north: (0, 200)
# south: (0, -200)


# We need to make vectors from other things to myself, and make them proportional to the
# inverse of their distance, so that
#     closer things repel me more than farther away things.

# Idea: get the vector from the other to me.
# Then, set magnitude to     1000.0 / magnitude



import turtle

verbose = False

class Vector:
    def __init__(self, x=0, y=0):
        self._x = x
        self._y = y
        self._computeMag()

    def _computeMag(self):
        self._mag = (self._x * self._x + self._y * self._y) ** 0.5

    def getX(self):
        return self._x

    def getY(self):
        return self._y

    def setX(self, newX):
        self._x = newX
        self._computeMag()
        
    def setY(self, newY):
        self._y = newY
        self._computeMag()

    def __str__(self):
        return "<" + str(self._x) + ", " + str(self._y) + ">"

    def __add__(self, other):
        return Vector(self._x + other._x, self._y + other._y)

    def getMagnitude(self):
        return self._mag

    def normalize(self):
        self._x /= self._mag
        self._y /= self._mag
        self._computeMag()

    def reverse(self):
        self._x = -self._x
        self._y = -self._y
        self._computeMag()

    def scale(self, amt):
        self._x *= amt
        self._y *= amt
        self._computeMag()

    def __abs__(self):
        return Vector(abs(self._x), abs(self._y))

    def __cmp__(self, other):
        mag1 = self.getMagnitude()
        mag2 = other.getMagnitude()
        if mag1 < mag2:
            return -1
        elif mag1 == mag2:
            return 0
        else:
            return 1
        

class Wall:
    def __init__(self, fromX, fromY, toX, toY):
        # assert that we are dealing with horizontal or vertical walls for now.
        assert fromX == toX or fromY == toY
        self._fromX = fromX
        self._fromY = fromY
        self._toX = toX
        self._toY = toY

    def vect2other(self, other):
        """Given another object on which we can do getX() and getY(), if I am
        a horizontal wall, return a vertical vector from my x to
        the object's x.  If I'm vertical, compare y's and return a similar vector."""
        if self._fromY == self._toY:   # horizontal wall
            # print "This wall is horiz"
            return Vector(0, other.getY() - self._fromY)
        else:
            # print "This wall is vertical"
            return Vector(other.getX() - self._fromX, 0)


class Person:

    # Used to make a unique name for each Person that is created.
    personCount = 0

    def __init__(self, x, y, name=None):
        self._x = x
        self._y = y
        if name is None:
            self._name = "Person " + str(Person.personCount)
            Person.personCount += 1
        else:
            self._name = name
        self._turt = turtle.Turtle()
        self._turt.penup()
        self._turt.hideturtle()
        self._turt.goto(self._x, self._y)
        self._turt.showturtle()
        # self._turt.pendown()

    def getX(self):
        return self._x
    def getY(self):
        return self._y
    def setX(self, newX):
        self._x = newX
    def setY(self, newY):
        self._y = newY
    def __str__(self):
        return self._name + " @ (" + str(self._x) + ", " + str(self._y) + ")"

    def vect2other(self, other):
        """Given another object on which we can do getX() and getY(),
        return a Vector from my (x, y) to its (x, y)"""
        return Vector(other.getX() - self._x, other.getY() - self._y)

    def move(self, walls, people):
        '''Look around myself and determine which direction I should move to get
        away from the other people and the walls.  Then, move myself.'''

        if verbose:
            print "top of move:", person

        dists = []
        for other in walls + people:
            if other == self:
                continue
            v = other.vect2other(self)
            if verbose:
                print "Vector before scaling is:", v

            mag = v.getMagnitude()

            # Now, normalize the vector, then multiply by 1 / magnitude to scale it
            # back up (and make longer magnitudes shorter and shorter ones longer, because
            # farther-away-things should have less influence).
            v.normalize()
            v.scale(1.0 / mag)
            if verbose:
                print "Vector after scaling is", v
            dists.append(v)

        # Sort them.
        dists.sort()

        # take the NUM largest (the last NUM), i.e., the 5 closest objects.
        NUM = 5
        dists = dists[-NUM:]
        
        # sum them up.
        dirToMove = Vector(0, 0)
        for d in dists:
            dirToMove = dirToMove + d

        if verbose:
            print "dirToMove ends up at ", dirToMove

        # normalize it
        dirToMove.normalize()
        if verbose:
            print "Normalized = ", dirToMove

        # scale
        # dirToMove.scale(MOVEDIST)

        self._x += dirToMove.getX()
        self._y += dirToMove.getY()
        # self._turt.settiltangle(self._turt.towards(self._x, self._y))
        self._turt.goto(self._x, self._y)


        if verbose:
            print self._name, "now at ", self


people = []

def addPerson(x, y):
    '''Called from main loop to add a new person'''
    global people
    people.append(Person(x, y))

# ---------- main ------------

WIDTH = 400
HEIGHT = 300


scr = turtle.Screen()
scr.setup(width=WIDTH, height=HEIGHT)
scr.screensize(WIDTH, HEIGHT)
scr.setworldcoordinates(0, HEIGHT, WIDTH, 0)

scr.onscreenclick(addPerson)


# Create the outside walls
northWall = Wall(0, 0, WIDTH, 0)
westWall = Wall(0, 0, 0, HEIGHT)
eastWall = Wall(WIDTH, 0, WIDTH, HEIGHT)
southWall = Wall(0, HEIGHT, WIDTH, HEIGHT)
walls = [northWall, westWall, eastWall, southWall]

# create one people (for testing)
pers = Person(100, 100)     # a little north west of the center
people.append(pers)


while True:

    for person in people:
        person.move(walls, people)

    if verbose:
        print "=" * 50


