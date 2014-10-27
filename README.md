## Notes Introduction

Create a simple notes synchronizing through multiple devices

### Installation 

> git clone git@github.com:golden-illusion/notes.git

> cd notes

> meteor update

> meteor

If everything ok, this app is ready on `localhost:3000`

### Features

1. CRUD notes
2. Augument events for CRUD: blur, cancel and enter
3. user management
4. writing package to wrap autolinker library: https://atmospherejs.com/hieudang/autolinker-wrapper
5. implement auto detect link for `notes`

### Bugs

1. when create note, enter will create 2 notes
2. when note have only link, double click to edit note is difficult

### TO-DO

1. Apply template
2. fix bugs
3. rewrite event for smartphone
