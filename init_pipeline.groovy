import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition

def JOB_NAME = "secure-model-pipeline"
def GIT_URL = "https://github.com/..."
def GIT_BRANCH = "main"

def jenkins = Jenkins.getInstance()
if (jenkins.getItem(JOB_NAME) == null) {
	println("Seeding pipeline job '${JOB_NAME}'")

	// Create pipeline job
	def job = jenkins.createProject(WorkflowJob.class, JOB_NAME)

	// Point at the Jenkinsfile int he repo
	def flowDef = new CpsScmFlowDefinition(
		new hudson.plugins.git.GitSCM(
			GIT_URL,
			[GIT_BRANCH],
			false,
			[],
			null,
			null,
			[]
		),
		"Jenkinsfile"
	)
	job.setDefinition(flowDef)
	job.save()

	println("Job '${JOB_NAME}' created pointing at ${GIT_URL}@${GIT_BRANCH}")
} else {
	println("Job '${JOB_NAME}' already exists; skipping seeding.")
}