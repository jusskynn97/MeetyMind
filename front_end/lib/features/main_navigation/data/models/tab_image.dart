class TabImage {
  final int id;
  final String imagePath;
  final String name;

  TabImage({
    required this.id,
    required this.imagePath,
    required this.name,
  });
}

List<TabImage> navBtn = [
  TabImage(id: 0, imagePath: 'assets/icon/home.png', name: 'Home'),
  TabImage(id: 1, imagePath: 'assets/icon/search.png', name: 'Search'),
  TabImage(id: 2, imagePath: 'assets/icon/heart.png', name: 'Like'),
  TabImage(id: 3, imagePath: 'assets/icon/notification.png', name: 'notification'),
  TabImage(id: 4, imagePath: 'assets/icon/user.png', name: 'Profile'),
];