/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package tfc_agent_mig_vm_packer

import (
	"fmt"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestTfcAgentMigVmPacker(t *testing.T) {
	bpt := tft.NewTFBlueprintTest(t, tft.WithRetryableTerraformErrors(tft.CommonRetryableErrors, 2, 3*time.Second))

	bpt.DefineVerify(func(assert *assert.Assertions) {
		bpt.DefaultVerify(assert)

		projectId := bpt.GetStringOutput("project_id")
		region := "us-central1"
		migName := bpt.GetStringOutput("mig_name")
		migInstanceGroup := bpt.GetStringOutput("mig_instance_group")

		gcloudArgs := gcloud.WithCommonArgs([]string{"--project", projectId, "--region", region, "--format=json"})
		op := gcloud.Run(t, fmt.Sprintf("compute instance-groups managed describe %s-mig", migName), gcloudArgs)

		assert.Equal(op.Get("autoscaler.status").String(), "ACTIVE", "Autoscaler should have ACTIVE status")
		assert.Equal(op.Get("status.isStable").String(), "true", "Instance group stability flag should be true")
		assert.Equal(op.Get("instanceGroup").String(), migInstanceGroup, "Instance group URL should match")
	})

	bpt.Test()
}
