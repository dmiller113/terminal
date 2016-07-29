module.exports = function(grunt) {
  // Do grunt-related things in here
  grunt.initConfig({
    coffee: {
      compileJoined: {
        options: {
          join: true
        },
        files: {
          'src/script/js/main.js': ['src/script/coffee/**/*.coffee'] // concat then compile into single file
        }
      }
    },
    watch: {
      options: {
        livereload: 15723
      },
      scripts: {
        files: [
          'src/script/coffee/**/*.coffee',
          'src/template/*.html',
        ],
        tasks: ['coffee'],
      },
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.registerTask('default', ['coffee', 'watch'])

}
