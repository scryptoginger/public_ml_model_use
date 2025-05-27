pipeline {
	agent {
		docker {
			image "secure-model-env:latest"
			args "-i"
		}
	}

	environment {
		MODEL_DIR = 'model'
		OUTPUT_DIR = 'output'
	}

	stages {
		stage('[1/9] Prepare Workspace') {
			steps { sh "mkdir -p $MODEL_DIR $OUTPUT_DIR" }
		}

		stage('[2/9] Download Model') {
			steps { sh "python3 scripts/download_model.py --output-dir $MODEL_DIR" }
		}

		stage('[3/9] Pre-use Scan') {
			steps { 
				sh '''
					bash scripts/scan.sh "$MODEL_DIR" --output "$OUTPUT_DIR/scan_pre.json"
				'''
			}
		}

		stage('[4/9] Modify Model') {
			steps { sh "python3 scripts/modify_model.py --model-dir $MODEL_DIR" }
		}

		stage('[5/9] Post-use Scan') {
			steps { sh "bash scripts/scan.sh $MODEL_DIR --output $OUTPUT_DIR/scan_post.json" }
		}

		stage('[6/9] Checkout') {
			steps { 
				deleteDir()
				checkout scm
			}
		}

		stage('[7/9] Package Model') {
			steps { sh "bash scripts/package_model.sh model output" }
		}

		stage('[8/9] Archive Artifacts') {
			steps {
				sh 'ls -l "${OUTPUT_DIR}"'
				archiveArtifacts artifacts: "$OUTPUT_DIR/*.json, $OUTPUT_DIR/*.zip, $OUTPUT_DIR/*.kit",
					fingerprint: true
      		}
		}

		stage('[9/9] Export Job Results') {
			steps {
				sh '''
					mkdir -p /workspace/job_results
					cp -r "$OUTPUT_DIR"/* /workspace/job_results/
				'''
				echo "Jenkins job results can be found in the new folder 'job_results'"
      		}
		}
	}

	post {
		always {
			echo "Pipeline finished. Check artifacts in the build\'s 'Artifacts' section."
		}
	}
}