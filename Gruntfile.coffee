module.exports = (grunt) ->
    # Project configuration.
    grunt.initConfig
        coffee:
            app:
                cwd: 'resources/coffee'
                src: ['*.coffee']
                dest: 'public_html/javascripts/'
                expand: true
                ext: '.js'
        stylus:
            app:
                cwd: 'resources/stylus'
                src: ['*.styl']
                dest: 'public_html/stylesheets/'
                expand: true
                ext: '.css'
        watch:
            app:
                files: 'resources/coffee/*.coffee, resources/stylus/*.styl'
                tasks: ['coffee', 'stylus']

    # These plugins provide necessary tasks.
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    # Default task.
    grunt.registerTask 'default', ['coffee, stylus, watch']
