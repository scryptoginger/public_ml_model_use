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
	}

	stages {
		stage('[1/8] Prepare Workspace') {
			steps {
				sh "mkdir -p $MODEL_DIR $OUTPUT_DIR"
				echo "Done! Next stage...(download the model)"
			}
		}

		stage('[2/8] Download Model') {
			steps {
				sh "python3 scripts/download_model.py --output-dir $MODEL_DIR"
				echo "Done! Next stage...(pre-use modelscan)"
			}
		}

		stage('[3/8] Pre-use Scan') {
			steps {
				sh "bash scripts/scan.sh $MODEL_DIR --output $OUTPUT_DIR/scan_pre.json"
				echo "Done! Next stage...(mock modifying model)"
			}
		}

		stage('[4/8] Modify Model') {
			steps {
				sh "python3 scripts/modify_model.py --model-dir $MODEL_DIR"
				echo "Done! Next stage...(post-use modelscan)"
			}
		}

		stage('[5/8] Post-use Scan') {
			steps {
				sh "bash scripts/scan.sh $MODEL_DIR --output $OUTPUT_DIR/scan_post.json"
				echo "Done! Next stage...(package your 'new' model)"
      		}
		}

		stage('[6/8] Package Model') {
			steps {
				sh "python3 scripts/package_model.py --model-dir $MODEL_DIR --output-dir $OUTPUT_DIR"
				echo "Done! Next stage...(archive the artifacts)"
			}
		}

		stage('[7/8] Archive Artifacts') {
			steps {
				sh 'ls -l "${OUTPUT_DIR}"'
				archiveArtifacts \
					artifacts: "$OUTPUT_DIR/*.json, $OUTPUT_DIR/*.zip, $OUTPUT_DIR/*.kit",
					fingerprint: true
				echo "Done! Next stage...(copy job results to repo root dir)"
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