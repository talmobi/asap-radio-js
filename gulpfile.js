var gulp = require('gulp'),
    uglify = require('gulp-uglify'),
    concat = require('gulp-concat');

gulp.task('default', function() {
  return gulp.src('js/*.js')
  .pipe(concat('asap-radio.min.js'))
  .pipe(uglify())
  .pipe(gulp.dest(''));
});