# PSTextAdventure
 Powershell Text Adventure<br>
<br>
This project was created to learn powershell scripting but was abandoned due to powershell performance issues.<br>
<br>
The original idea was to create a text based game similar in a similar style to Dwarf Fortress<br>
To do this an array of characters is used as a draw buffer similar to OpenGL.<br>
Currently there is the ability to view a randomly generated world with grass and trees.<br>
<br>
To run this project<br>
Set execution policy to Unrestricted<br>
Run the following command to set an environment variable require to make drawing smoother "$e = [char]0x1b"<br>
<br>
There are 2 main scripts<br>
<br>
game.ps1 contains the MainMenu (Game was never integrated into the menu, see below to run game)<br>
No functionality in this script is available other than menu controls.
Arrow keys, Enter and Esc are menu controls<br>
<br>
old/gameOLD2.ps1 contains the actual game code<br>
WASD to move view<br>
Arrow Keys to move cursor<br>

![image](https://user-images.githubusercontent.com/11240849/195278759-f2d1b01c-a449-4c02-9956-61de353813ea.png)

![image](https://user-images.githubusercontent.com/11240849/195278883-3138b839-967d-4e08-8a38-229a491e40bb.png)
