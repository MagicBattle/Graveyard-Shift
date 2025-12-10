



# Graveyard Shift #

## Summary ##

**A first person 3D horror game inspired by Poppy Playtime and Five Nights at Freddy’s where you work the graveyard shift inspecting playrooms for an upcoming park launch while avoiding an animatronic name Willie.**

## Project Resources

[Web-playable version of your game](https://magicbattle.itch.io/graveyard-shift)

[Proposal](https://docs.google.com/document/d/1nR5DYf_2luAt4GnkOczyh9kR6Yd4S6YwB5Mn2vxp6f4/edit?tab=t.0#heading=h.i3tv2mxf7h7z)


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

## User Interface and Input - Tanner Nguyen

### Main Menu

<img src="https://cdn.discordapp.com/attachments/691024545858977842/1447784308793282713/Screenshot_2025-12-07_215118.png?ex=6938e1b5&is=69379035&hm=2e8d36f22f7ca8d433e23bbbfffc3009200ca3a285db89f8b48e39f1b86fcbb1&" width=50%>

The main menu is the first screen the user sees when playing the game. It was made using a 3D node that contains decorations such as floors, roofs, monster(Willie), etc. with a CanvasLayer displaying the UI of the title of the game and buttons to play or exit. The font used in the text and throughout is [Futura Condensed Extra Bold](https://font.download/font/futura-condensed-extra).

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

## Sub-Roles ##

## Narrative Design - Tanner Nguyen

### How the Narrative was created?
With the help of our initial plan, it was hard to start on the narrative since we were still gathering assets and learning how to use Godot in 3D so I focused more on creating the UI. After we started to have a plan on how we created our game, I thought of adding narrative to the game on how we got into working this graveyard shift. The first thought is to create dialogue where the player talks to himself based on specific events. Second, I wanted to introduce the game with a phone call to let the player know that he has to work the graveyard shift due to the AI behavior systems being tampered by Willie. Lastly, I thought it would be cool to create a job instruction video on what to do for the job which I got inspiration from the [Los Pollos Hermanos Employee Training Video](https://www.youtube.com/watch?v=B9RgougnhiE).

### Dialogue
To create the dialogue, I added a function on player_screen.gd where it creates dialogue given the dialogue text and the duration of the dialogue. To make it functional, I added trigger zones to the map where if a player enters the area3D, it generates dialogue with the trigger_zone.gd script. There are also instances where I called the functions through different nodes such as whenever [the player wins the playrooms](https://github.com/MagicBattle/Graveyard-Shift/blob/e8b7ca83d098895268b258b75c70d250eb671914/-graveyard-shift/scripts/redgreeenlight.gd#L139). To make the dialogue correlate to the lore, I created the dialogue for the playrooms so that the player is reviewing the playrooms thinking if this would be suited for kids in their upcoming park launch. And for extra dialogue, I created trigger zones for specific paintings and create unique dialogue for each painting.

### Phone Call
For the phone call, I wanted to create the script on how the player got the graveyard shift. Since our monster is an animatronic, I wanted the script to be related to his AI behavior being malfunctioned to hurt people similar to [Five Nights at Freddy's](https://www.youtube.com/watch?v=egYTAXLRsqM). To punish the players from failing the playrooms, Willie is connected to the playrooms from being signaled on who failed his playrooms. After explaining that, the player is later being lead to the CEO's office to watch the job instruction video by picking up the code from Michael's desk. 

I created the phonecall by using an AI generated voice from a website called [ElevenLabs](https://elevenlabs.io/) where I used my script and generated the prompt with an additions to adding emotion to specific phrases. Then I add a [voice changer](https://voicechanger.io/) to the audio by making it sound like the phone guy is calling through the phone. Finally, I put everything together by adding a [VHS](https://pixabay.com/sound-effects/real-vhs-169982/) and a [phone hang up](https://pixabay.com/sound-effects/phone-hang-up-46793/) sound in the audio using [Audacity](https://www.audacityteam.org/).

### Job Instruction Video
<img src="https://cdn.discordapp.com/attachments/691024545858977842/1447835197704765522/Screenshot_2025-12-08_221924.png?ex=6939111a&is=6937bf9a&hm=9d6361dff5dddd2329d6465f1fdd0ed94b4cb502093575854f08053383e02c10&" width=50%>

For the job instruction video, I decided to use that idea of the Los Pollos Hermanos training video and apply it to this game. Since our animatronic is Willie Steamboat, I partnered up with my brother Milton to become the Steamboat Brothers for the company to launch the park named Willomania. The script mainly consisted of insructing the player on what to do for the shift which is to create written feedback on their upcoming playrooms for the park launch. The goal of the video is to make it very happy and friendly so that the player feels welcomed, but in reality there is something offputting of working this shift such as a subtle dialogue saying "Someone is always watching". After we recorded our script, I teamed up with my friend Aaron to edit the job instruction video with the details I have given him such as using the Willie Steamboat animation on the background, having background music, creating our logo, and being black and white. The video turned out great and fitted really well with the atmosphere of the game. You can watch the full video [here](https://www.youtube.com/watch?v=xpkm42Flkt0).

### Narrative Resources
- [Inspiration of Job Instruction Video](https://www.youtube.com/watch?v=B9RgougnhiE)
- [Inspiration of Phone Call](https://www.youtube.com/watch?v=egYTAXLRsqM)
- [AI voice](https://elevenlabs.io/)
- [Phone Voice Changer](https://voicechanger.io/)
- [VHS Sound](https://pixabay.com/sound-effects/real-vhs-169982/)
- [Phone Hang Up](https://pixabay.com/sound-effects/phone-hang-up-46793/)
- [Creating Phone Call](https://www.audacityteam.org/)

### Personal Documentation
- [My Job Instruction Video](https://www.youtube.com/watch?v=xpkm42Flkt0)
- [My Script of Creating Narrative](https://docs.google.com/document/d/16bUkw53hS28XqzKTecJW9URzkf5nXKt8TeOyDU_JcQ4/edit?usp=sharing)


## Other Contributions ## 

## Main Roles ## 
## Producer - Michael Yeung 

## Sub-Roles ##
## Gameplay Testing 

## Other Contributions ##  

## Main Roles ## 

## Sub-Roles ##

## Other Contributions ##  

## Main Roles ## 

## Sub-Roles ##

## Other Contributions ##  

## Main Roles ## 

## Sub-Roles ##

## Other Contributions ##  

## Main Roles ## 

## Sub-Roles ##

## Other Contributions ## 


 ## Lance Arnoco ##

 ### Main Role - Movement/Physics ###
 
[Link to Initial Movement that was our basis](https://github.com/MagicBattle/Graveyard-Shift/tree/d9c5290f41c8bc4a87d810e448e0b73c3ed6b488/-graveyard-shift/scripts)
Initial Movement
Camera Patch
With Base Movement 

Final Crouching Fix
[Link to ShapeCast3D Adjustment](https://github.com/MagicBattle/Graveyard-Shift/tree/a7aef0b2faca6385f434189fa574e241dc5a7178/-graveyard-shift/scenes)
Using RayCast3D did not cover the whole model which allowed the player to spam crouch to clip through walls
To counter this I changed the RayCast3D to a ShapeCast3D directly the size of the player as making it smaller could leave a margin that the player can still be able to combine throwing the ball directly downward and crouch spamming to clip through the map


Initial Throw and Current Throw Strength
[Initial Throw Commit](https://github.com/MagicBattle/Graveyard-Shift/tree/ff28f46ee893e0297738bd98d18480dc3d8301f7/-graveyard-shift)
Created Initial Throwable Object Scene (Later scrapped for Dhruv’s Throwable Scene)
Implemented Throwing Hold Strength Throw

Leaning
- Added Leaning to be able to look over different cubicles to toss objects
- Inspired by Rainbow Six Siege leaning mechanic

### Secondary Role - Visual Cohesion and Style Guide ###
- Did not implement anything visually cohesive (Mostly Michael)
- Group votes on how we want to implement the menus
  - Death Screen (Tanner)
  (https://discord.com/channels/@me/982525679373549578/1448443261617311907)
  - Shader (Michael)
  - Visuals
(https://discord.com/channels/@me/982525679373549578/1448443331859451974)
  - Cutscenes

Group Votes to a majority of how our design process worked.

In terms of map layout, most structures were made and managed by Michael, so when we were creating maps we focused on using only assets from this package
https://amos-makes.itch.io/psx-office-pack


### Additionals ###
