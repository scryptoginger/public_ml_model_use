pipeline {
	agent {
		docker {
			image "secure-model-env:latest"
			args "-i"
		}
	}

	environment {
		MODEL_DIR = "${WORKSPACE}/model"
		OUTPUT_DIR = "${WORKSPACE}/output"
	}

	stages {
		stage('[1/8] Prepare Workspace') {
			steps { 
				sh '''
					mkdir -p "$MODEL_DIR" "$OUTPUT_DIR" 
				'''
			}
		}

		stage('[2/8] Download Model') {
			steps { 
				sh '''
					python3 scripts/download_model.py --output-dir "$MODEL_DIR"
				'''
			}
		}

		stage('[3/8] Pre-use Scan') {
			steps { 
				sh '''
					bash scripts/scan.sh "$MODEL_DIR" --output "$OUTPUT_DIR/scan_pre.json"
				'''
			}
		}

		stage('[4/8] Modify Model') {
			steps { 
				sh '''
					python3 scripts/modify_model.py --model-dir "$MODEL_DIR" 
				'''
			}
		}

		stage('[5/8] Post-use Scan') {
			steps { 
				sh '''
					bash scripts/scan.sh "$MODEL_DIR" --output "$OUTPUT_DIR/scan_post.json" 
				'''
			}
		}

		stage('[6/8] Package Model') {
			steps { 
				sh '''
					bash scripts/package_model.sh "$MODEL_DIR" "$OUTPUT_DIR" 
				'''
			}
		}

		stage('[7/8] Archive Artifacts') {
			steps {
				sh 'ls -l "${OUTPUT_DIR}"'
				archiveArtifacts artifacts: "output/*.digest, output/*.json",
					fingerprint: true
      		}
		}

		stage('[8/8] Export Job Results') {
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