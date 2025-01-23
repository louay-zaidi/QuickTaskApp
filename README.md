# QuickTasks: A Task Management App

## A. Name and Matriculation Number
**Name**: Louay Zaidi  
**Matriculation Number (Matricola)**: 338949

---

## B. Title of the Project
**Title**: QuickTasks: Task Management Made Easy

---

## C. Short Overview
QuickTasks is a Flutter-based task management app designed to simplify daily planning and organization. With features such as task creation, status tracking, and holiday integration into the calendar, QuickTasks helps users maintain focus on their goals. The app supports multiple languages (English and Italian) and remembers the user's last selected language for a seamless experience. Additionally, users can switch between light and dark modes to suit their preferences. Tasks not marked as completed by the end of the day are automatically categorized as "Missed."

---

## D. User Experience Overview
The app's intuitive user interface enables users to manage tasks effortlessly. Below are some common user actions and how they are performed:

1. **Adding a Task**:
   - Tap the "+" button in the bottom navigation bar.
   - Enter task details (title, description, status) and save the task.

2. **Editing or Changing Task Status**:
   - Select any task from the "My Tasks" screen to edit its details or update its status.

3. **Deleting a Task**:
   - Swipe left on a task in the "My Tasks" screen to reveal the delete option.
   - Confirm deletion in the popup dialog.

4. **Viewing All Tasks and Holidays**:
   - Open the calendar screen via the bottom navigation bar.
   - View all tasks alongside public holidays fetched from an API.

### Screenshots
 through this link : https://drive.google.com/drive/folders/1d97lFx2TsjOCfYSOE5KjmKDxXkHMIyQW?usp=sharing
---

## E. Technology

### Dart/Flutter Packages
- **Provider**: For state management, ensuring efficient and scalable updates across the app.
- **Hive**: A lightweight and fast database for storing tasks locally, enabling offline functionality.
- **Flutter Localizations**: For multi-language support (English and Italian).
- **intl**: To handle date formatting and localization effectively.
- **http**: For fetching holidays data from a remote API.

### Noteworthy Implementation Choices
- **Localization**: The app dynamically switches between English and Italian and remembers the last selected language using Hive for persistent storage.
- **Custom Navigation Control**: Navigation between screens is restricted to the bottom navigation bar to improve user experience and avoid accidental swipes.
- **Dark Mode Toggle**: Users can easily switch between light and dark themes via the settings in the app's drawer.
- **Holiday Integration**: Public holidays are fetched from an API and displayed in the calendar view to provide contextual information to users.
- **Missed Tasks**: Any task not marked as "Completed" by the end of the day is automatically set to "Missed."

### Challenges and Solutions
1. **Swipe Gesture Blocking**:
   - Issue: By default, `PageView` allowed swipe gestures to navigate between screens, which conflicted with the bottom navigation bar design.
   - Solution: A custom `PageView` with `physics: NeverScrollableScrollPhysics()` was implemented to block swipes and enforce navigation through the bottom navigation bar.

2. **Localization Persistence**:
   - Issue: Remembering the last selected language required persistent storage.
   - Solution: Hive was used to store the user's language preference, which is loaded on app startup.

3. **Holiday Data Consumption**:
   - Issue: Integrating real-time holiday data required fetching from a remote API.
   - Solution: The `http` package was utilized to retrieve and display holiday data dynamically within the calendar.

---

QuickTasks is a lightweight yet feature-packed task management app designed with simplicity and practicality in mind. With its focus on user-friendly design and robust functionality, QuickTasks offers an ideal solution for daily productivity management.

