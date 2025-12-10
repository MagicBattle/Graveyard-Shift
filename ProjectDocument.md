# Graveyard Shift

## Summary

**A first person 3D horror game inspired by Poppy Playtime and Five Nights at Freddy’s where you work the graveyard shift inspecting playrooms for an upcoming park launch while avoiding an animatronic name Willie.**

## Project Resources

[Web-playable version of your game](https://magicbattle.itch.io/graveyard-shift)

[Proposal](https://docs.google.com/document/d/1nR5DYf_2luAt4GnkOczyh9kR6Yd4S6YwB5Mn2vxp6f4/edit?tab=t.0#heading=h.i3tv2mxf7h7z)

## Gameplay Explanation

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**

**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure

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

_Short Description_ - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
_Procedural Terrain_ - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

Add addition contributions int he Other Contributions section.

## Main Roles

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

## Sub-Roles

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

## Other Contributions

## Main Roles

## Producer - Michael Yeung

## Sub-Roles

## Gameplay Testing

## Other Contributions

--

## Benjamin Huynh

## Main Roles

## Animations & Visuals

### Enhanced dialogue box visuals

<img src="https://cdn.discordapp.com/attachments/1420981170107322388/1448432796086571129/image.png?ex=693b3da9&is=6939ec29&hm=fc7aea79abecd0405f60171b0a41b004e2cf0cd59b9fa41c4bae27d39623a395&" width=50%>
The dialogue functionality was already implemented by Tanner. I felt like it was a bit too simple so I enhanced it a bit. I enhanced the dialogue by builing the dialogue UI using a CanvasLayer that holds a Panel with a custom translucent StyleBoxFlat to get the rounded, blurred PSX-style background. Inside it, I used a RichTextLabel for wrapped text and bold formatting, along with a drop-shadow for readability. On top of that, I added a simple typewriter effect by revealing the label’s text one character at a time through a timed via GDScript. Finally, I anchored the whole UI to the bottom of the screen so the dialogue always sits in a consistent position across resolutions.

### Creating and enhancing the doorpin UI

<img src="https://cdn.discordapp.com/attachments/1420981170107322388/1448432980812107928/image.png?ex=693b3dd5&is=6939ec55&hm=cb1815e464e865253269abfdf4801c2d8a027b71b959ea480844c94cc0b10441&" width=50%>
I created the entire Doorpin UI. I built the keypad screen as a CanvasLayer containing a central Panel with a custom StyleBoxFlat to get the thick PSX-style border. Inside the panel, I used a VBoxContainer for the title, PIN display, and instruction text, and a GridContainer to lay out the number buttons in a 3×3 way like any other pinpads in which all of them are button nodes with a custom font and shadow to match the rest of the UI.

I also implemented the entire Doorpin pad functionality. I added the keypad system by giving each door a uses_pin_pad flag, a pin_code, and a reference to the pin_pad_ui.tscn scene. When the player interacts with a locked door that uses a pin pad which I gave a separate scene called "LockedDoor" to differentiate from the normal doors. Each LockedDoor has its own special code which is edited through Inspector. I instantiate the UI through \_ensure_pin_pad_ui() and show it with \_show_pin_pad(). The door listens to signals emitted by the UI

### Enhanced the deathscreen scene

To make the deathscreen more visually appealing and enhanced, on top of the shader that was already implemented by Michael, I enhanced by adding fade-in effect so that the death-screen doesnt appear instantaneous. To do that, I implemented ColorRect modulate in animations.

### Implemented Door functionality

I built the door system around a pivot object that rotates between a closed angle and an open angle using the tween functionality (which could technically be count as animation). When the player or monster enters the door’s interaction area, the script starts listening for the interact button which is F and leaving the area stops all interaction and closes the door if auto-close is enabled. If the door is locked and uses a keypad, the script brings up the PIN UI and waits for the correct code before unlocking which is implemented in the LockedDoor scene. Once unlocked, the door smoothly swings open, plays the sound I implemented also, and notifies the NoiseManager so other systems can react. The whole script handles opening, closing, locking, unlocking, and even through the tutorial/phase-based rules all in one place so each door behaves consistently.

## Sub-Roles

## Sounds

Although my main role was Animations and Visuals, I felt like I spent much more time implementing the sounds of the game. The sound role was a very important factor to the game as it is also part of the game logic and you would want the horror game vibes. Implementing the sounds was also significantly more difficult in this project than the Animations and Visuals itself as a lot of the Animations and Visuals we have were imported and for the sounds, there were many different factors that I need to worry about such as decibels and radius, and most crucially, the timing of when the sound is played.

### Ambience Sounds

I sourced looping ambient tracks that matched our late-night facility vibe with the typical scary ambience. This was inspired from Minecraft with the cave ambience which to this day still scares me. This really fits the horror game we are making. I set up three layers of audio in the main.gd script which are looping ambience, random ambient stingers, and a rotating background music playlist. For ambience, I created two AudioStreamPlayers that loop wind and duct-rumble tracks continuously at different volumes and pitches to give the office vibes. For stingers, I added a dedicated player to add the scary ambience sounds along with a timer in which every 40–75 seconds, a random ambience plays and plays it with slight pitch variation, and automatically stop it after few seconds to create unpredictable tension. For the general background music, I built a small shuffle system playlist in which a music player loads a randomized tracks, plays one until it finishes, then automatically selects the next with a slight pitch offset to make it feel different.

### Footsteps

I also set up separate footsteps for sprinting versus walking and panned the audio slightly to mirror the player’s camera movement. Same goes for Willie. I implemented the footsteps by giving the player an AudioStreamPlayer3D and controlling when it plays based on movement speed and whether the player is grounded. Each frame, I measure horizontal velocity and if the player is moving on the floor, I increment a timer and trigger a footstep sound whenever the timer exceeds a calculated interval. That interval shrinks or grows depending on how fast the player depending if the player is walking or sprinting, giving natural spacing between steps. In the early stages, the footsteps felt uneven. I also adjust the pitch slightly using the speed ratio so footsteps sound faster when running to give it more realism. If the player stops, jumps, or UI locks movement, I stop the audio and reset the timer to avoid leftover sounds. Initially the sounds kept on playing. Same idea goes for the Willie script but in more simple term. If Willie walks, he gives a consistent footstep that can only be heard from a certain radius using AudioStreamPlayer3D and goes into sprint mode with a different faster footstep in the chase/storm state.

### Monster State Change Sound Transitions

I used the existing dictionary of states that Aidan implemented and then store a set of audio clips for each monster state, each one with a unique growl and then played the correct sound whenever the state changed. Inside \_transition_state(), I call \_play_state_change_sound(), which randomly picks one of the clips from that state’s list, assigns it to the state_audio AudioStreamPlayer3D called "StateAudio" which then slightly randomizes the pitch, and plays it. This gives each state its own distinct audio cue without any brute force coding.

### The playroom sounds

I implemented some quick sound effects for each of the gamerooms such as Victory, Defeat, Click, Light swap, Balloon pop, etc. by timing it with the scripts of the respecitve playrooms. Each sound is spatialized and volume-tweaked so it feels like it’s coming from props in the environment rather than a global source using AudioStream3DPlayer in their respective playrooms. Initially it was in the global source so you can hear the light swaps even through the tutorial room.

These sounds were sourced from [Pixabay](https://pixabay.com/sound-effects/search/victory/) with this one as an example.

### Other Sounds

I implemented miscellaneous cues such as UI button clicks in the Menu and door swing sounds.

## Other Contributions

## Main Roles

## Sub-Roles

## Other Contributions

## Main Roles

## Sub-Roles

## Other Contributions

## Main Roles

## Sub-Roles

## Other Contributions
