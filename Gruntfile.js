'use strict';

module.exports = function (grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  grunt.initConfig({
    watch: {
      test: {
        files: ['<%= watch.coffee.files %>', 'test/**/*'],
        tasks: ['test']
      },
      coffee: {
        files: 'src/**/*.coffee',
        tasks: ['coffeelint:src', 'coffee:src']
      }
    },
    coffeelint: {
      options: {
        'max_line_length': {
          value: 120
        }
      },
      src: [
        'src/**/*.coffee'
      ],
      test: [
        'test/*.coffee'
      ],
      example: [
        'examples/**/*.coffee'
      ]
    },
    coffee: {
      src: {
        expand: true,
        cwd: 'src',
        src: ['**/*.coffee'],
        dest: 'lib',
        ext: '.js'
      },
      test: {
        expand: true,
        cwd: 'test',
        src: ['**/*.coffee'],
        dest: 'test_lib',
        ext: '.js'
      }
    },
    clean: {
      src: ['lib'],
      test: ['test_lib'],
      coverage: ['coverage.html']
    },
    copy: {
      src: {
        expand: true,
        cwd: 'src',
        src: ['**/*.js'],
        dest: 'lib'
      }
    },
    mochaTest: {
      test: {
        options: {
          reporter: 'list',
          require: 'blanket'
        },
        src: ['test_lib/**/*.js']
      },
      'html-cov': {
        options: {
          reporter: 'html-cov',
          quiet: true,
          captureFile: 'coverage.html'
        },
        src: ['test_lib/**/*.js']
      },
      'travis-cov': {
        options: {
          reporter: 'travis-cov'
        },
        src: ['test_lib/**/*.js']
      }
    },
    release: {
      options: {
        npm: false
      }
    }
  });

  grunt.registerTask('test', [
    'compile',
    'mochaTest'
    // 'clean:test'
  ]);

  grunt.registerTask('build', 'compile');
  grunt.registerTask('compile', [
    'clean:src',
    'copy:src',
    'coffeelint:src',
    'coffee:src',
    'coffee:test'
  ]);

  grunt.registerTask('default', [
    'test',
    'watch'
  ]);
};
