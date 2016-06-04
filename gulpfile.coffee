gulp           = require 'gulp'
coffee         = require 'gulp-coffee'
stylus         = require 'gulp-stylus'

gulp.task 'coffee', ->
	gulp.src('resources/coffee/*.coffee')
    .pipe coffee bare: true
	.pipe gulp.dest('public_html/javascripts/')

gulp.task 'stylus', ->
    gulp.src('resources/stylus/*.styl')
    .pipe(stylus(compress: true))
    .pipe gulp.dest('public_html/stylesheets/')

# The default task
gulp.task 'default', ->
    gulp.run 'stylus', 'coffee'

    gulp.watch 'resources/coffee/**', ->
        gulp.run 'coffee'

    gulp.watch 'resources/styles/**', ->
        gulp.run 'styles'