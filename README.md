> When the user open the app the first code who
> is going to excetute is the code below this.
> In this code the app will get the info
> to knew if the user is logged with an acount
> or is not. Depend if the user is logged the app
> will go automatic to the HomeScreen or if is not
> the app is going to go to the LoginScreen.
> All this funcionality is possible becuase when the user
> Sign in or Sign up his credential are saved in the CoreData
> and if the user Log Out to the app this credential was eliminated. 
```swift
func autoLogIn() {
        let context = PersistenceService.context
        let fechtRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuarios")
        
        do {
            let result = try context.fetch(fechtRequest)
            
            for data in result as! [NSManagedObject] {
                email = data.value(forKey: "email") as! String
                id = data.value(forKey: "id") as! String
            }
            if(!email.isEmpty && !id.isEmpty) {
                goToHomePage()
            }
        } catch {
            print("ERROR, SOMETHING WRONG")
        }
    }.
```


# LoginScreeen

![N|Solid](https://user-images.githubusercontent.com/44836587/72724788-92a17c80-3b84-11ea-8479-638d86fcf5ce.png)

That's the first view in the app. Using Firebase the user could execute three funcionalities:

  - If the user have already an account Login with this account.
  - Login in to the app with his google account.
  - If the user don't have an account will register in the app clicking in the bottom text

# RegisterScreeen
![N|Solid](https://user-images.githubusercontent.com/44836587/72724787-92a17c80-3b84-11ea-89d2-521c66d8a6ef.png)

If the user want to create an account for use the app for the first time or get multiples account in this screen would get the posibility for fill this three fields and sign up in Firebase Firestone and the App.

# HomeScreeen
![N|Solid](https://user-images.githubusercontent.com/44836587/72724792-933a1300-3b84-11ea-8145-c282383c12b4.png)

That's the most important screen in the app.
When you Sign in or Sign up an navigate to this Screen the app takes your location and prints in to the Apple Maps.
If the user wants the route for travel to anyplace only need move the "pin" into the place who want to arrive and click the GO button, automatically in the maps appear many routes for arrive to this place.
Also in the bottom of the Maps a label with the direction of the "pin" is going to appear for show us the address.

# ProfileScreeen
![N|Solid](https://user-images.githubusercontent.com/44836587/72724790-92a17c80-3b84-11ea-8ef6-6244a6654ecd.png)

This screen its a simple screen who allows the user knew the username, useremail and userid information for the user who was logged.

# SignOutPopUp
![N|Solid](https://user-images.githubusercontent.com/44836587/72724789-92a17c80-3b84-11ea-82ea-f9739a277226.png)

Basic Pop-Up in case you want to Log Out to the app.
If you Log Out your credentials from CoreData will be deleted for the next time not implements the auto login.

### Pods

| Pods | README |
| ------ | ------ |
| Firebase | [pods/firebase/documentation][Pf] |
| FirebaseFirestore | [pods/firebasefirestore/README.md][Pff] |
| GoogleSignIn | [pods/googlesignin/documentation][Pgsi] |
| TextFieldEffects | [pods/textfieldeffects/README.md][Ptfe] |

Make sure if you want to test the app first in the terminal go to the proyect finder and run `pod install` for upload all the pods includes in the app.

License
----

Manuel Espeso Martin


**Free Software, Hell Yeah!**
  	
   [Pf]: <https://firebase.google.com/docs/ios/setup?hl=es-419>
   [Pff]: <https://github.com/firebase/firebase-ios-sdk>
   [Pgsi]: <https://firebase.google.com/docs/auth/ios/google-signin?hl=en>
   [Ptfe]: <https://github.com/raulriera/TextFieldEffects>
