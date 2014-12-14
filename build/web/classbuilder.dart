import "dart:html";
import "package:logging_handlers/logging_handlers_shared.dart";
import "dart:convert" show JSON;
import "dart:async" show Future;

final String SPRITESHEET_PATH = "packages/classbuilder/images/content/classImages/spritesheets";

//TODO: parse from JSON file
List<Character> characters;

UListElement classSelectorList;
ImageElement charCards;

Character selectedChar;

void main() {
    startQuickLogging();

    Character.loadClassSelectorImages().then((_) {
        characters = [new Character("Alchemist", "Rogue"), new Character("Arcane Warrior", "Mage"), new Character("Assassin", "Rogue"), new Character("Elementalist", "Mage"), new Character("Hunter", "Rogue"), new Character("Katari", "Warrior"), new Character("Keeper", "Mage"), new Character("Legionaire", "Warrior"), new Character("Necromancer", "Mage"), new Character("Reaver", "Rogue"), new Character("Templar", "Warrior")];
    });
}


class Character {
    String name;
    String id;
    List<String> abilities = [];
    List<String> attributes = [];
    String classType;
    SpriteImage charCard;
    SpriteImage charCardGrey;

    DivElement charCardDiv;

    static List<String> charCardsInfo = [];

    Character(this.name, this.classType) {
        debug("Character:const() - $name");
        id = name.toLowerCase().replaceAll(new RegExp(r' '), "_");
        charCard = getSpriteInfo(charCardsInfo, "card");
        charCardGrey = getSpriteInfo(charCardsInfo, "card", true);
        setupClassSelectorImage();
        //TODO: load abilities
    }

    SpriteImage getSpriteInfo(List<String> infoList, String type, [bool grey = false, bool small = true]) {
        debug("getSpriteInfo() - char:${name}, type:${type}, variant:${grey}, small:${small}");
        SpriteImage image;
        infoList.forEach((spriteInfo) {
            if (spriteInfo["filename"].contains(id) && spriteInfo["filename"].contains(type) && (spriteInfo["filename"].contains("grayOverlay") == grey) && (spriteInfo["filename"].contains("small") == small)) {
                debug("Found sprite in spriteInfo");
                image = new SpriteImage(spriteInfo["frame"]["x"], spriteInfo["frame"]["y"], spriteInfo["frame"]["w"], spriteInfo["frame"]["h"]);
            }
        });
        if (image == Null) error("couldn't find sprite in info");
        return image;
    }

    void setupClassSelectorImage() {
        classSelectorList = querySelector("#classSelector ul");
        LIElement newLi = new LIElement();

        newLi.onMouseEnter.listen((_) {
            changeClassSelectorImage(active: true);
        });

        newLi.onMouseLeave.listen((_) {
            changeClassSelectorImage();
        });

        newLi.onClick.listen((_) {
            selectedChar = this;
            characters.forEach((char) {
                char.changeClassSelectorImage();
            });
        });

        charCardDiv = new DivElement();
        changeClassSelectorImage();
        newLi.append(charCardDiv);

        ParagraphElement charName = new ParagraphElement();
        charName.text = name;
        newLi.append(charName);

        classSelectorList.children.add(newLi);
    }

    void changeClassSelectorImage({bool active}) {
        //if selected
        if (identical(selectedChar, this) || active == true) {
            info("${id} set classSelectorImage to active");
            charCardDiv.style.width = charCard.width.toString() + "px";
            charCardDiv.style.height = charCard.height.toString() + "px";
            charCardDiv.style.background = "url(${SPRITESHEET_PATH}/character-cards.png) no-repeat -${charCard.x}px -${charCard.y}px";
        } else {
            info("${id} set classSelectorImage to inactive");
            charCardDiv.style.width = charCardGrey.width.toString() + "px";
            charCardDiv.style.height = charCardGrey.height.toString() + "px";
            charCardDiv.style.background = "url(${SPRITESHEET_PATH}/character-cards.png) no-repeat -${charCardGrey.x}px -${charCardGrey.y}px";
        }
    }

    static Future loadClassSelectorImages() {
        charCards = new ImageElement(src: "${SPRITESHEET_PATH}/character-cards.png");
        Future charCardsJsonFuture = HttpRequest.getString("${SPRITESHEET_PATH}/character-cards.json").then((String fileContents) {
            info("charCards info loaded");
            Map charCardsPositions = JSON.decode(fileContents);
            Character.charCardsInfo = charCardsPositions["frames"];
            debug(Character.charCardsInfo.toString());
        });

        var futures = [charCards.onLoad.first, charCardsJsonFuture];

        return Future.wait(futures).then((_) {
            info("charCards loaded");
        });
    }
}

class SpriteImage {
    int x;
    int y;
    int width;
    int height;

    SpriteImage(this.x, this.y, this.width, this.height) {
        debug("SpriteImage:const() - $x $y $width $height");
    }

    SpriteImage.fromString(String x_, String y_, String width_, String height_) {
        debug("SpriteImage.fromString:const() - $x_ $y_ $width_ $height_");
        x = int.parse(x_);
        y = int.parse(y_);
        width = int.parse(width_);
        height = int.parse(height_);
    }
}
