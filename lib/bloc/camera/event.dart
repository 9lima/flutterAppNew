sealed class PictureEvent {}

class LoadKeys extends PictureEvent {}

class PictureEmpty extends PictureEvent {}

class PictureInit extends PictureEvent {}

class PictureChangeLens extends PictureEvent {}

class PictureChangeFlash extends PictureEvent {}

class PictureTaken extends PictureEvent {}

class PickPictureFromGallery extends PictureEvent {}

class PictureUpload extends PictureEvent {}

class PictureDispose extends PictureEvent {}
