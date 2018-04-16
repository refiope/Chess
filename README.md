-Project started Mar. 30th. 2018
-Project finished Apr. 16th. 2018

-Not planning ahead in specific detail was my biggest mistake before I went on ahead with this project

thinking this will be easy (setup.txt file was the only planning I did). By the time I realized I approached

this project the wrong way, I invested too much time and effort already.

I thought about giving up couple times during the two week period of working on this thing when

I faced a tough bug or a problem I had no idea how to fix (until I had to actually sit down and write things down

step by step and figure things out from the beginning, and this happened more than once). As there were more lines of code,

bugs became more hazy and out of grasp. I had to assume things (which I know it's not a good thing to do) on where the

code went wrong and tried to fix it, hoping that fixing it will also get rid of the bug, instead of knowing that it will.

Seriously, I thought about not only giving up the project but also programming itself.

-If I had to pick two things that really slowed me down, it would be pawn and king. Pawn is the most unique piece out of

them all, I realized while working on the project (four out of five special moves are from pawn).

It's normal move does not take enemy piece, but when a piece is placed diagonal to the pawn, it can take the piece. All other pieces'

normal moves can take opponent's piece along its movement while pawn can't, which means I would have to code special case

for pawn whenever something has to be done with the whole board. So instead of doing that, I had to make the regular move of pawns into special move,

while the attack move of pawn had to be regular move. But problem came when I had to code moves for king. Since pawn's regular move isn't really

'regular' (it's available only when there's an enemy piece diagonal to pawn's position), I had to make a clone of the board, simulate the cloned board and

move the ally king and see if enemy pawn is in position to check the king. But cloning the board was a bad idea. It should have been clear, but when

an object's attributes are messed with, even when there are duplicates, the value would change for both the duplicate and the original. So instead of

using a clone (I did use a clone somewhere else and I made sure that no values of objects were messed with) and using object method, I had to manually

code the pawn's possible moves. The problem didn't end there. Calling #get_next method (method that gets next possible moves for a piece) for king called

get_next for all opponent pieces (to not let ally king move in to check), including the opponent's king. Writing this seems easy to solve the problem, but

it was not very clear at the moment and did not realize that #get_next method for king was recursive. I could ramble more about all the bugs and problems I've

encountered but I'll stop with these examples for now.

-The lesson I got from working on this project is:

1. Plan ahead and try to be as specific as possible. Do try to predict abnormalities or oddities out of the normal rules, and think about what type of data to use for certain things.

2. Make sure to be organized. For example, know which method uses what other methods, and what variables.

3. You can't duplicate objects. Learn to work around it.

4. Work on the bug/problem step by step, and be calm. Don't get discouraged.

5. Try not to assume where in the code the bug is causing/what the problem is. It's a bad habit.
