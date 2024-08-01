Kinito Localisation System
---

Currently on **HOLD** until a Proof of Concept mod is made to aid in "MODIFYING" the `your_world` / `-Scenes/NewInstance/1` scene (Secondary Montior Scare changes are allowed.)
Right now, a AUD$20 Bounty is on the line for this proof of concept mod.

Current Bounty Progress:
----
A method has been found and has been published. However is in a massively WIP state and installation is more-so weird compared to API like mods (ModConfig and !KinitoAPI) and can not replicate the project on my end for this project.
https://github.com/reckdave/MultiInstance

Bounty Rules:
----
- Modification of (or requesting the player to modify) the `.pck` file is **NOT ALLOWED** and would be considered pirating if providing with one to the player.
- Video proof **MUST** be shown for this concept mod.
- Nodes within `your_world` (`ACT3/FunFair`, `ACT3/Home` (and by extension: `ACT3/Home/Scenese/Feild`),  `ACT3/Player` and `ACT3/StartUp`) MUST BE EDITABLE through this concept mod. (Node renaming or replacement is good enough)
- A GitHub repository containing your godot project **MUST** be submitted.
- The project **MUST** be a KinitoPET Mod project (Getting Started and Mod Structure here: https://www.kinitopet.com/docs) and **MUST** be able to be compiled into a `.zip` file that KinitoPET can understand as a mod.

Allowance:
----
- I can allow fake windows for `your_world`, so long as the overall experience is not different from vanilla playthroughs. (This means a recreation of the `your_world` application window that is near indistinguisable to Windows 10's application windows)

I have no end date goal as this is what is essentially blocking process for the localization mod overall and a majority of mods to be developed.

FAQ:
----
1) Why is this bounty up?

KinitoPET's mod loader is built differently compared to preestablished Godot 3 and Godot 4 Mod loaders.  
KinitoPET uses disconnected [scene trees](https://docs.godotengine.org/en/3.3/classes/class_scenetree.html#class-scenetree) for the use of multiple windows (as the game is built in Godot 3.3.3 and doesn't utilise custom windows found in Godot 4+),  
one of those running from `-Scenes/NewInstance/0` (We will call this Instance 0) for the main game itself (Which is also where all of the mods are loaded from and stored into).  
The other (`-Scenes/NewInstance/-1`, we will call this Instance -1 as although the game calls for `-Scenes/NewInstance/1`, it only done by Instance -1 for your_world and the endings) does periodic checks (once every second) with a spesific file to see if the contents change telling the game to launch something into the second window.  
This is only used for 4 cases (Spoiler Warning for KinitoPET):
1. The Jade "Split in half" jumpscare during the "Factory Frenzy" minigame in the Web World. (This requires the user to have 2 or more monitors connected as Jade is found on the far right of the second monitor).
2. A "Rug Doctor Woman Ad" / "The What" face shown faintly on the second montior during the second half of the survey scene (the ones before "Are you afraid of the dark?")
3. The window for `your_world` (this is used as Kinito is on Instance 0 as just a transparent window on the empty desktop).
4. The "Will you stay with me?" question box and associated ending effects (the full white fade in for "Trapped" and the desktop glitching effect for "No escape")

The major issue with this leads two fold, one with how Instance -1 reads the files and the other, the inability to modify cross-scene tree.  
The first one sounds odd, but there has been an issue where players notice that `your_world` runs EXTREMELY SLOW to the point of unplayability (not to be associated with the lag from the home scene, that's just unoptimised grass).  
It was quickly found out that the way the game reads these files is by first setting the engine FPS for the spesific scene tree to `1`, this is fine in terms of the intended application (reading the single file once a second). The game is able to swap the FPS back to `30`, but for weird reasons it is unable to. Causing the extreme slow down when launching your_world.

The other is more of a reliability issue. Due to how the game is split in two, the only way to communicate with eachother is to do IPC methods, the game uses file-based communication between both scene trees.  
It's like two children who can't contact their sibling because 1) they are way too far away and 2) their parents don't exist.

This bounty is set up to open possibilities for even newer modders to help solve this near "impossible" problem in due time and hopefully help localise the entire game in the process.

TL;DR Two root scene tree objects can't modify each other easily.

---

2) Why can't the mod loader be placed into AutoStart like other Mod Loaders?

It's a good question to ask, and we have asked Troy to hopefully impliment this fix. But currently, he has 1) not been able to launch the correct custom godot branch (which includes GodotSteam and other modifications) to build KinitoPET currently, and 2) Troy has classified the game as "dead / complete" (in some aspects, please don't harras devs thx.) and is currently making a new game (he's a solo dev at 18 and used tons of spagetti code back then at 15).
