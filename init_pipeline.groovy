import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.UserRemoteConfig
import hudson.plugins.git.BranchSpec
import hudson.plugins.git.GitSCM
import java.util.Collections

def JOB_NAME = "secure-model-pipeline"
def GIT_URL = "https://github.com/scryptoginger/public_ml_model_use.git"
def GIT_BRANCH = "main"

Jenkins j = Jenkins.get()
if (j.getItem(JOB_NAME) == null) {
	println("Seeding pipeline job '${JOB_NAME}'")

	// Create pipeline job
	WorkflowJob job = j.createProject(WorkflowJob, JOB_NAME)

	// Point at the Jenkinsfile int he repo
	UserRemoteConfig remote = new UserRemoteConfig(GIT_URL, null, null, null)
	GitSCM scm = new GitSCM(
		[remote],
		[new BranchSpec("*/${GIT_BRANCH}")],
		false,
		Collections.emptyList(),
		null,
		null,
		Collections.emptyList()
		)

	CpsScmFlowDefinition flowDef = new CpsScmFlowDefinition(scm, "Jenkinsfile")
	job.setDefinition(flowDef)
	job.save()

	println("Job '${JOB_NAME}' created pointing at ${GIT_URL}@${GIT_BRANCH}")
} else {
	println("Job '${JOB_NAME}' already exists; skipping seeding.")
}