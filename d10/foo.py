
with open('./d10/in.txt') as f:
    lines = f.readlines()

lines = [l.strip() for l in lines]


for idx, l in enumerate(lines):
    if l.find('S') != -1:
        S = (idx, l.find('S'))
        break

distances = {S: 0}
previous = {S: None}
router = []

lefts = []
rights = []

def find_next(current, pipe):
    global distances
    global lines
    if pipe == 'L':
        if (current[0], current[1] + 1) not in distances:
            return (current[0], current[1] + 1)
        elif (current[0] - 1, current[1]) not in distances:
            return (current[0] - 1, current[1])
    if pipe == 'F':
        if (current[0], current[1] +1 ) not in distances:
            return (current[0], current[1] + 1)
        elif (current[0] + 1, current[1]) not in distances:
            return (current[0] + 1, current[1])
    if pipe == '7':
        if (current[0], current[1] - 1) not in distances:
            return (current[0], current[1] - 1)
        elif (current[0] + 1, current[1]) not in distances:
            return (current[0] + 1, current[1])
    if pipe == 'J':
        if (current[0], current[1] - 1) not in distances:
            return (current[0], current[1] - 1)
        elif (current[0] - 1, current[1]) not in distances:
            return (current[0] - 1, current[1])
    if pipe == '-':
        if (current[0], current[1] - 1) not in distances:
            return (current[0], current[1] -1)
        elif (current[0], current[1] + 1) not in distances:
            return (current[0], current[1] +1)
    if pipe == '|':
        if (current[0] - 1, current[1]) not in distances:
            return (current[0] - 1, current[1])
        elif (current[0] + 1, current[1]) not in distances:
            return (current[0] + 1, current[1])
    return None

def find_first(current):
    global lines
    new = []
    check = lines[current[0]][current[1] - 1]
    if check == '-' or check == 'L' or check == 'F':
        new.append((current[0], current[1] - 1))
        return new
    check = lines[current[0]][current[1] + 1]
    if check == '-' or check == '7' or check == 'J':
        new.append((current[0], current[1] + 1))
        return new
    check = lines[current[0] - 1][current[1]]
    if check == '|' or check == '7' or check == 'F':
        new.append((current[0] - 1, current[1]))
        return new
    check = lines[current[0] + 1][current[1]]
    if check == '|' or check == 'L' or check == 'J':
        new.append((current[0] + 1, current[1]))
        return new
    return new

current = S
pipe = 'S'

next = find_first(current)

route = []
route.append(current)

for n in next:
    distances[n] = 1
    previous[n] = S

while len(next) > 0:
    current = next.pop(0)
    route.append(current)
    pipe = lines[current[0]][current[1]]

    news = find_next(current, pipe)

    if news is not None:
        distances[news] = distances[current] + 1
        previous[news] = current
        next.append(news)

high = 0
for k in distances:
    if distances[k] > high:
        high = distances[k]

def dir(current, prev):
    return (current[0] - prev[0], current[1] - prev[1])

lefts = []
rights = []
used = set(route)

def inside(position):
    global lines
    if (position[0] < 0 or position[1] < 0):
        return False
    if (position[0] >= len(lines) or position[1] >= len(lines[0])):
        return False
    return True

def over(position):
    return position[0] - 1, position[1]
def under(position):
    return position[0] + 1, position[1]
def toleft(position):
    return position[0], position[1] - 1
def toright(position):
    return position[0], position[1] + 1

for current in route:
    if current == S:
        prev =  route[-1]
        next = route[1]

        frm = dir(current, prev)
        to = dir(next, current)
        if (frm == (0,1) and to == (0,1)) or (frm == (0,-1) and to == (0, -1)):
            pipe = '-'
        if (frm == (1,0) and to == (1,0)) or (frm == (-1,0) and to == (-1,0)):
            pipe = '|'
        if (frm == (1,0) and to == (0,1)) or (frm == (0,-1) and to == (-1,0)):
            pipe = 'L'
        if (frm == (0, 1) and to == (1, 0)) or (frm == (-1,0) and to == (0, -1)):
            pipe = '7'
        if (frm == (0, 1) and to == (-1, 0)) or (frm == (1,0) and to == (0, -1)):
            pipe = 'J'
        if (frm == (-1, 0) and to == (0, 1)) or (frm == (0,-1) and to == (0, 1)):
            pipe = 'F'
        
    else:
        prev = previous[current]
        pipe = lines[current[0]][current[1]]

    direction  = dir(current, prev)

    if direction == (0, 1): # right
        if pipe == '-':
            below = under(current)
            if below not in used and inside(below):
                rights.append(below)
            above = over(current)
            if above not in used and inside(above):
                lefts.append(above)
        if pipe == '7':
            right = toright(current)
            if right not in used and inside(right):
                lefts.append(right)
            above = over(current)
            if above not in used and inside(above):
                lefts.append(above)
        if pipe == 'J':
            right = toright(current)
            if right not in used and inside(right):
                rights.append(right)
            below = under(current)
            if below not in used and inside(below):
                rights.append(below)
    if direction == (0, -1): # left
        if pipe == '-':
            below = under(current)
            if below not in used and inside(below):
                lefts.append(below)
            above = over(current)
            if above not in used and inside(above):
                rights.append(above)
        if pipe == 'L':
            below = under(current)
            if below not in used and inside(below):
                lefts.append(below)
            left = toleft(current)
            if left not in used and inside(left):
                lefts.append(left)
        if pipe == 'F':
            left = toleft(current)
            if left not in used and inside(left):
                rights.append(left)
            above = over(current)
            if above not in used and inside(above):
                rights.append(above)
    if direction == (1, 0):
        if pipe == '|':
            left = toleft(current)
            if left not in used and inside(left):
                rights.append(left)
            right = toright(current)
            if right not in used and inside(right):
                lefts.append(right)
        if pipe == 'J':
            right = toright(current)
            if right not in used and inside(right):
                lefts.append(right)
            below = under(current)
            if below not in used and inside(below):
                lefts.append(below)
        if pipe == 'L':
            left = toleft(current)
            if left not in used and inside(left):
                rights.append(left)
            below = under(current)
            if below not in used and inside(below):
                rights.append(below)
    if direction == (-1, 0):
        if pipe == '|':
            left = toleft(current)
            if left not in used and inside(left):
                lefts.append(left)
            right = toright(current)
            if right not in used and inside(right):
                rights.append(right)
        if pipe == 'F':
            left = toleft(current)
            if left not in used and inside(left):
                lefts.append(left)
            above = over(current)
            if above not in used and inside(above):
                lefts.append(above)
        if pipe == '7':
            right = toright(current)
            if right not in used and inside(right):
                rights.append(right)
            above = over(current)
            if above not in used and inside(above):
                rights.append(above)

route = set(route)

if (len(lefts) < len(rights)):
    searches = lefts
else:
    searches = rights

areas = []


while len(searches) > 0:
    elem = searches.pop(0)
    if elem in areas:
        continue
    areas.append(elem)

    up = (elem[0] - 1, elem[1])

    if up not in areas and inside(up) and up not in route:
        searches.append(up)
    
    down = (elem[0] + 1, elem[1])
    if down not in areas and inside(down) and down not in route:
        searches.append(down)
    
    left = (elem[0], elem[1] - 1)
    if left not in areas and inside(left) and left not in route:
        searches.append(left)

    
    right = (elem[0], elem[1] + 1)
    if right not in areas and inside(right) and right not in route:
        searches.append(right)
    
print(len(areas))



#route = ''
#
#for i,l in enumerate(lines):
#    for j, c in enumerate(l):
#        if (i, j) in distances:
#            route += c
#        else:
#            route += ' '
#    route += '\n'
#
#print(route)
