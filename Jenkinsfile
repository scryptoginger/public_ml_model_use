pipeline {
	agent {
		docker {
			image "secure-model-env:latest"
			args "-i"
		}
	}

	environment {
		MODEL_DIR = "model"
		OUTPUT_DIR = "output"
		// POLICY_FILE = "config/default_scan.yaml"
	}

	stages {
		stage('Prepare Workspace') {
			steps {
				sh "mkdir -p $MODEL_DIR $OUTPUT_DIR"
				echo "Done! Next stage..."
			}
		}

		stage('Download Model') {
			steps {
				sh "python3 scripts/download_model.py --output-dir $MODEL_DIR"
				echo "Done! Next stage..."
			}
		}

		stage('Pre-use Scan') {
			steps {
				sh "bash scripts/scan.sh $MODEL_DIR --output $OUTPUT_DIR/scan_pre.json"
				echo "Done! Next stage..."
			}
		}

		stage('Modify Model') {
			steps {
				sh "python3 scripts/modify_model.py --model-dir $MODEL_DIR"
				echo "Done! Next stage..."
			}
		}

		stage('Post-use Scan') {
			steps {
				sh "bash scripts/scan.sh $MODEL_DIR --output $OUTPUT_DIR/scan_post.json"
				echo "Done! Next stage..."
      		}
		}

		stage('Package Model') {
			steps {
				sh "python3 scripts/package_model.py --model-dir $MODEL_DIR --output-dir $OUTPUT_DIR"
				echo "Done! Next stage..."
			}
		}

		stage('Archive Artifacts') {
			steps {
				archiveArtifacts \
					artifacts: [
						"$OUTPUT_DIR/*.json",
						"$OUTPUT_DIR/*.zip", 
						"$OUTPUT_DIR/*.kit"
					], \
					fingerprint: true
      		}
		}
	}

	post {
		always {
			echo "Pipeline finished. Check artifacts in the build\'s 'Artifacts' section."
			junit allowEmptyResults: true, testResults: "$OUTPUT_DIR/*.json"
		}
	}
}