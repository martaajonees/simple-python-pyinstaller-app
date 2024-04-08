pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py'
                stash(name: 'compiled-sources', includes: 'sources/*.py')
            }
        }
    }
}