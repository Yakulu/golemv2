var gulp = require('gulp');
var coffee = require('gulp-coffee');
var sourcemaps = require('gulp-sourcemaps');

var csfiles = ['public/scripts/**.coffee','public/scripts/golem/**.coffee'];

gulp.task('coffee', function () {
  gulp.src(csfiles, { base: './' })
    .pipe(sourcemaps.init())
    .pipe(coffee().on('error', console.log))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('./'))
});

var watcher = gulp.watch(csfiles, ['coffee']);
watcher.on('change', function(event) {
  console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
});

gulp.task('default', function () {});
