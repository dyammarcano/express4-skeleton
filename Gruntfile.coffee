module.exports = (grunt) ->
    # Project configuration.
    grunt.initConfig
        coffee:
            build:
                cwd: 'resources/coffee'
                src: ['*.coffee']
                dest: 'public_html/javascripts/'
                expand: true
                ext: '.js'
            watch:
                files: 'resources/coffee/*.coffee'
                spawn: false
                tasks: ['default']
        stylus:
            build:
                cwd: 'resources/stylus'
                compress: true
                src: ['*.styl']
                dest: 'public_html/stylesheets/'
                expand: true
                ext: '.css'
            watch:
                files: 'resources/stylus/*.styl'
                spawn: false
                tasks: ['default']
        watch:
            scripts:
                tasks: ['coffee', 'stylus']
                options:
                    livereload: true
                    event:['all']

    # These plugins provide necessary tasks.
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    # Default task.
    grunt.registerTask 'default', ['watch']