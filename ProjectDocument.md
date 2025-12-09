

## User Interface and Input - Tanner Nguyen

### Main Menu

<img src="https://cdn.discordapp.com/attachments/691024545858977842/1447784308793282713/Screenshot_2025-12-07_215118.png?ex=6938e1b5&is=69379035&hm=2e8d36f22f7ca8d433e23bbbfffc3009200ca3a285db89f8b48e39f1b86fcbb1&" width=50%>

The main menu is the first screen the user sees when playing the game. It was made using a 3D node that contains decorations such as floors, roofs, monster(Willie), etc. with a CanvasLayer displaying the UI of the title of the game and buttons to play or exit. The font used in the text and throughout is [Futura Condensed Extra Bold](https://font.download/font/futura-condensed-extra)

### Player Screen
<img src="https://cdn.discordapp.com/attachments/691024545858977842/1447786492457128081/Screenshot_2025-12-08_190525.png?ex=6938e3be&is=6937923e&hm=f2d86e9a4b4514a29786e3b78058df99403ea285bf520654a0fe3dcde72c799e&" width=50%>

This is the UI of the player screen with all of the essential elements of the game that are all under the main scene UI node except for Inventory and ViewModel. On the bottom left corner is the stamina bar which was created by using a ProgressBar over an icon(TextureRect) to display the sprint icon. On the left is the ObjectiveUI which is a NinePatchRect using a black shade texture from an asset pack. It contains a HBoxContainer with the question mark icon(TextureRect) and a label that contains a objective.gd script that can change the label of the objective such as setting an objective. On the top right corner is the CodesUI that follows the same concept of the ObjectiveUI by using NinePtchRect, icon, and label to display the codes use to unlock the doors. On the right is the ControlsUI that displays the controls of the game during the tutorial using a label. On the bottom right corner is the throwBar that follows the same creation as the stamina bar, but the bar is only shown when charging a throw on a throwable. On the slightly middle of screen with text is the DialogueLabel that can display custom text in player_screen.gd script for the player to contain dialogue throughout the game. The label also uses an AnimationPlayer that fades in and out the text displayed.

In the player scene contains Inventory and ViewModel. On the bottom of the screen is the inventory where the player can store throwable items to throw and distract Willie. It contains an invetory.gd and inventory_bar.gd scripts where inventory proccesses logic based on when the inventory slots changes by using signals and inventory bar updates the slots by highlighting and updating slots by loading the icon path. [Here is an example of the item path](https://github.com/MagicBattle/Graveyard-Shift/blob/e8b7ca83d098895268b258b75c70d250eb671914/-graveyard-shift/scripts/player.gd#L95-L101). Lastly, the viewmodel was created by adding a canvaslayer node containing a RayCast3D and a ViewModel node containing viewmodel.gd script under Camera3D that shows the held item by finding the first mesh instance of that item which is seen from the floating paper ball on the screen.

When pressing the 'esc' key, it will bring you to the pause menu(Not displayed on the image) that gives you an option to resume or exit the game. This is implemented by the game_manager.gd script that Dhruv created where the scene of the game freezes and displays a mouse cursor for you to interact with the UI buttons.

### Jumpscare
<img src="https://cdn.discordapp.com/attachments/691024545858977842/1447794954133967048/Screenshot_2025-12-08_193941.png?ex=6938eb9f&is=69379a1f&hm=4ac9acabf970c4408935439bb0cd7425b735c1be51ad002deba6a0668b815e46&" width=50%>

This is the Jumpscare scene that is triggered when you are close to Willie. It was created using Willie's mesh, background/floor mesh, and spotlight that plays a jump over animation imported by Michael. It contains a jumpscare.gd script that shakes the camera for one second by decaying the shake intensity.

### Death Screen
<img src="https://cdn.discordapp.com/attachments/691024545858977842/1447796858201309295/Screenshot_2025-12-08_194716.png?ex=6938ed65&is=69379be5&hm=0b3e8ae81df22c8bba90f672762788e750703213485efd9586960ff85a947ee4&" width=50%>

This is the death scene that triggers after the jumpscare scene. It follows the same creation of the jumpscare scene but displays a UI to continue or exit the game. The "YOU DIED" label used a different font called [Volter Black](https://www.1001fonts.com/volter-font.html) to emphasis the text more on screen. The scene also uses a blur.gdshader founded by Michael to have a VHS effect to the death similar to the Five Nights at Freddy's game.

### UI Resources
- [Texture of Objective and Codes UI](https://waxx.itch.io/shadow-mines-asset-pack)
- [Question Mark Icon](https://www.freepik.com/free-vector/black-hand-painted-question-mark_148767885.htm#fromView=keyword&page=1&position=0&uuid=f5ded46c-e42e-4591-954e-5fcfb5bade8a&query=Spooky+question+mark)
- [Sprint Icon](https://www.flaticon.com/free-icon/running_1267761?term=run&page=1&position=4&origin=tag&related_id=1267761)
- [Throw Icon](https://www.flaticon.com/free-icons/throw)
- [Main Font](https://font.download/font/futura-condensed-extra)
- [YOU DIED Font](https://www.1001fonts.com/volter-font.html)
# The title of your game #

## Summary ##

**A paragraph-length pitch for your game.**

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1qwWCpMwKJGOLQ-rRJt8G8zisCa2XHFhv6zSWars0eWM/edit?usp=sharing)  

## Gameplay Explanation ##

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**


**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

# Team Member Contributions

This section be repeated once for each team member. Each team member should provide their name and GitHub user information.

The general structures is 
```
Team Member 1
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.

Team Member 2
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.
...
```

For each team member, you shoudl work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

Add addition contributions int he Other Contributions section.

## Main Roles ##

## Sub-Roles ##

## Other Contributions ##
