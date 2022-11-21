<template>
  <div >
    <cv-grid fullWidth>
      <cv-row>
        <cv-column class="page-title title-and-toolbar">
          <h2>{{ $t("virtualhosts.title") }}</h2>
        </cv-column>
      </cv-row>
      <cv-row v-if="error.length">
        <cv-column>
          <NsInlineNotification
            kind="error"
            :title="$t('action.get-configuration')"
            :description="error.getConfiguration"
            :showCloseButton="false"
          />
        </cv-column>
      </cv-row>
      <cv-row v-if="virtualhost.length && !loading.getConfiguration">
        <cv-column>
          <NsButton
            kind="primary"
            :icon="Add20"
            @click="showCreateVhostModal()"
            class="empty-state-button"
            >{{ $t("virtualhosts.create_virtualhost") }}
          </NsButton>
        </cv-column>
      </cv-row>
      <!-- empty state -->
      <cv-row v-if="!virtualhost.length && !loading.getConfiguration">
        <cv-column>
          <cv-tile kind="standard" :light="true">
            <NsEmptyState :title="$t('virtualhosts.no_virtualhost_configured')">
              <template #pictogram>
                <DataBase32 />
              </template>
              <template #description>
                <div>{{ $t("virtualhosts.empty_state_virtualhost_description") }}</div>
                <NsButton
                  kind="primary"
                  :icon="Add20"
                  @click="showCreateVhostModal()"
                  class="empty-state-button"
                  >{{ $t("virtualhosts.create_virtualhost") }}
                </NsButton>
              </template>
            </NsEmptyState>
          </cv-tile>
        </cv-column>
      </cv-row>

      <!-- domains -->
      <cv-row>
        <cv-column
          v-for="vhost in virtualhost"
          :key="vhost.name"
          :md="4"
          :max="4"
        >
          <NsInfoCard light :title="vhost.ServerNames[0]" :icon="DataBase32">
            <template #menu>
              <cv-overflow-menu
                :flip-menu="true"
                tip-position="top"
                tip-alignment="end"
                class="top-right-overflow-menu"
              >
                <cv-overflow-menu-item
                  danger
                  @click="showDeleteVhostModal(vhost)"
                >
                  <NsMenuItem
                    :icon="TrashCan20"
                    :label="$t('virtualhosts.delete')"
                  />
                </cv-overflow-menu-item>
                <cv-overflow-menu-item
                  @click="DisableVhost(vhost)"
                >
                  <NsMenuItem
                    :icon="Power20"
                    :label="vhost.status == 'enabled' ? $t('virtualhosts.disable_virtualhost') : $t('virtualhosts.enable_virtualhost')"
                  />
                </cv-overflow-menu-item>
              </cv-overflow-menu>
            </template>
            <template #content>
              <div class="card-rows">
                <div class="card-row">
                  <cv-link v-if="sftpgo_service && vhost.sftpgo_enabled"
                    :href="'http://' + hostname + path+'/web/client/login'"
                    target="_blank"
                    :inline="false"
                  >
                  {{ $t("virtualhosts.sftpgo_url") }}
                  <cv-tooltip
                    alignment="start"
                    direction="top"
                    :tip="$t('virtualhosts.sftpgo_login_tips',{user: isEdit ? Port: vhost.Port})"
                    class="info tooltip-mg-left"
                  >
                  </cv-tooltip>
                  </cv-link>
                  </div>
                  <div class="card-row">
                    <cv-tag
                      v-if="vhost.status == 'enabled'"
                      kind="green"
                      :label="$t('common.enabled')"
                      :title="$t('common.enabled')"
                    ></cv-tag>
                    <cv-tag
                      v-else
                      kind="red"
                      :label="$t('common.disabled')"
                      :title="$t('common.disabled')"
                    ></cv-tag>
                  </div>
                  <div class="card-row actions ">
                    <NsButton
                      kind="ghost"
                      :icon="Edit20"
                      @click="showEditVhostModal(vhost)"
                      >
                      {{ $t("virtualhosts.edit") }}
                    </NsButton>
                  </div>
              </div>
            </template>
          </NsInfoCard>
        </cv-column>
      </cv-row>
    </cv-grid>

    <NsDangerDeleteModal
      :isShown="isShownDeleteVhostModal"
      :name="currentVhost.ServerNames[0]"
      :title="$t('virtualhosts.delete')"
      :warning="$t('virtualhosts.please_read_carefully')"
      :description="$t('virtualhosts.delete_virtualhosts_confirm', { name: currentVhost.ServerNames[0]})"
      :typeToConfirm="
        $t('virtualhosts.type_to_confirm', { name:currentVhost.ServerNames[0] })
      "
      @hide="hideDeleteVhostModal"
      @confirmDelete="deleteDomain(currentVhost)"
    />

    <NsModal 
      :visible="isShownCreateVhostModal"
      @modal-hidden="hideEditRepoModal"
      @primary-click="SaveVhost"
      @secondary-click="hideEditRepoModal"
      size="default"
    >
      <template v-if="isEdit" slot="title">{{$t('virtualhosts.Edit_Virtualhosts',{name: TitleEditModal })}}</template>
      <template v-if="!isEdit" slot="title">{{$t('virtualhosts.Create_Virtualhosts')}}</template>
      <template slot="content">
        <cv-form @submit.prevent="SaveVhost">
          <!-- domain name -->
          <cv-text-area
            :label="$t('virtualhosts.ServerNames')"
            v-model.trim="ServerNames"
            :invalid-message="$t(error.ServerNames,{error:value.ServerNames})"
            :helper-text="
              $t('virtualhosts.Write_DomainNames')
            "
            :value="currentVhost.ServerNames"
            class="ServerNames"
            ref="ServerNames"
            :placeholder="$t('virtualhosts.write_one_domain_per_line')"
          >
          </cv-text-area>
          <NsToggle v-if="sftpgo_service"
            :label="$t('virtualhosts.sftpgo_enabled')"
            :value="sftpgo_enabled"
            :form-item="true"
            v-model="isSftpgoEnabled"
            :disabled="loading.getConfiguration || loading.configureModule"
            ref="sftpgo_enabled"
            class="mg-bottom"
          >
            <template slot="tooltip">
              <span
                v-html="$t('virtualhosts.sftpgo_explanation_tooltips')"
              ></span>
            </template>
            <template slot="text-left">{{ $t("virtualhosts.disabled") }}</template>
            <template slot="text-right">{{ $t("virtualhosts.enabled") }}</template>
          </NsToggle>
          <!-- ask lets encrypt -->
          <cv-toggle
            :value="letsencrypt"
            :label="$t('virtualhosts.lets_encrypt')"
            v-model="isLetsEncryptEnabled"
            :disabled="loading.getConfiguration || loading.configureModule"
            class="mg-bottom"
          >
            <template slot="text-left">{{
              $t("virtualhosts.disabled")
            }}</template>
            <template slot="text-right">{{
              $t("virtualhosts.enabled")
            }}</template>
          </cv-toggle>
          <!-- force https -->
          <cv-toggle
            :value="http2https"
            :label="$t('virtualhosts.http_to_https')"
            v-model="isHttpToHttpsEnabled"
            :disabled="loading.getConfiguration || loading.configureModule"
            class="mg-bottom"
          >
            <template slot="text-left">{{
              $t("virtualhosts.disabled")
            }}</template>
            <template slot="text-right">{{
              $t("virtualhosts.enabled")
            }}</template>
          </cv-toggle>
          <!-- Php version -->
          <cv-dropdown 
            :light="true"
            :value="currentVhost.PhpVersion"
            v-model="PhpVersion"
            :up="false"
            :inline="false"
            :helper-text="$t('virtualhosts.container_version_will_be_installed')"
            :hide-selected="false"
            :invalid-message="$t(error.PhpVersion)"
            :label="$t('virtualhosts.select_php_version')"
            :disabled="loading.getConfiguration || loading.configureModule">
            <cv-dropdown-item selected value="">{{$t('virtualhosts.PHP_none')}}</cv-dropdown-item>
            <cv-dropdown-item value="7.4">{{$t('virtualhosts.PHP_74')}}</cv-dropdown-item>
            <cv-dropdown-item value="8.0">{{$t('virtualhosts.PHP_80')}}</cv-dropdown-item>
            <cv-dropdown-item value="8.1">{{$t('virtualhosts.PHP_81')}}</cv-dropdown-item>
          </cv-dropdown>
          <!-- advanced options -->
          <cv-accordion ref="accordion">
            <cv-accordion-item :open="toggleAccordion[0]">
              <template slot="title">{{ $t("virtualhosts.advanced") }}</template>
              <template slot="content">
                <cv-toggle
                :value="indexes"
                :label="$t('virtualhosts.Indexes')"
                v-model="isIndexesEnabled"
                :disabled="loading.getConfiguration || loading.configureModule"
                class="mg-bottom"
                >
                <template slot="text-left">{{
                  $t("virtualhosts.disabled")
                }}</template>
                <template slot="text-right">{{
                  $t("virtualhosts.enabled")
                }}</template>
                </cv-toggle>
                <template v-if="PhpVersion">
                <cv-toggle
                :value="allowurlfopen"
                :label="$t('virtualhosts.AllowUrlfOpen')"
                v-model="isAllowUrlfOpenEnabled"
                :disabled="loading.getConfiguration || loading.configureModule"
                class="mg-bottom"
                >
                <template slot="text-left">{{
                  $t("virtualhosts.disabled")
                }}</template>
                <template slot="text-right">{{
                  $t("virtualhosts.enabled")
                }}</template>
                </cv-toggle>
                  <cv-slider
                    :light="true"
                    :label="$t('virtualhosts.select_php_memory_limit')"
                    :disabled="loading.getConfiguration || loading.configureModule"
                    :min="PostMaxSize"
                    :max="'2000'"
                    :value="MemoryLimit"
                    v-model="MemoryLimit"
                    :step="'1'"
                    :step-multiplier="'1'"
                    :min-label="$t('virtualhosts.Min')"
                    :max-label="$t('virtualhosts.Max')">
                  </cv-slider>
                  <cv-slider
                    :light="true"
                    :label="$t('virtualhosts.select_php_post_max_file_size_limit')"
                    :disabled="loading.getConfiguration || loading.configureModule"
                    :min="UploadMaxFilesize"
                    :max="'2000'"
                    :value="PostMaxSize"
                    v-model="PostMaxSize"
                    :step="'1'"
                    :step-multiplier="'1'"
                    :min-label="$t('virtualhosts.Min')"
                    :max-label="$t('virtualhosts.Max')">
                  </cv-slider>
                  <cv-slider
                    :light="true"
                    :label="$t('virtualhosts.select_php_upload_max_file_limit')"
                    :disabled="loading.getConfiguration || loading.configureModule"
                    :min="'4'"
                    :max="'2000'"
                    :value="UploadMaxFilesize"
                    v-model="UploadMaxFilesize"
                    :step="'1'"
                    :step-multiplier="'1'"
                    :min-label="$t('virtualhosts.Min')"
                    :max-label="$t('virtualhosts.Max')">
                  </cv-slider>
                  <cv-slider
                    :light="true"
                    :label="$t('virtualhosts.select_php_max_execution_time_limit')"
                    :disabled="loading.getConfiguration || loading.configureModule"
                    :min="'0'"
                    :max="'3600'"
                    :value="MaxExecutionTime"
                    v-model="MaxExecutionTime"
                    :step="'1'"
                    :step-multiplier="'1'"
                    :min-label="$t('virtualhosts.Min')"
                    :max-label="$t('virtualhosts.Max')">
                  </cv-slider>
                  <cv-slider
                    :light="true"
                    :label="$t('virtualhosts.select_php_max_file_upload_limit')"
                    :disabled="loading.getConfiguration || loading.configureModule"
                    :min="'20'"
                    :max="'20000'"
                    :value="MaxFileUploads"
                    v-model="MaxFileUploads"
                    :step="'1'"
                    :step-multiplier="'1'"
                    :min-label="$t('virtualhosts.Min')"
                    :max-label="$t('virtualhosts.Max')">
                  </cv-slider>
                </template>
              </template>
            </cv-accordion-item>
          </cv-accordion>
        </cv-form>
      </template>
      <template slot="secondary-button">{{ $t("virtualhosts.cancel") }}</template>
      <template slot="primary-button">{{ $t("virtualhosts.save") }}</template>
    </NsModal>
  </div>
</template>

<script>
import to from "await-to-js";
import { mapState } from "vuex";
import {
  QueryParamService,
  UtilService,
  TaskService,
  IconService,
} from "@nethserver/ns8-ui-lib";
import DataBase32 from "@carbon/icons-vue/es/data--base/32";
export default {
  name: "VirtualHosts",
  components:{ DataBase32},
  mixins: [TaskService, IconService, UtilService, QueryParamService],
  pageTitle() {
    return this.$t("virtualhosts.title") + " - " + this.appName;
  },
  data() {
    return {
      q: {
        page: "virtualhosts",
      },
      DataBase32,
      isShownCreateVhostModal: false,
      isShownDeleteVhostModal: false,
      path:"",
      sftpgo_service: false,
      letsencrypt:"",
      http2https:"",
      indexes:"",
      allowurlfopen:"",
      isEdit: false,
      isDisable:false,
      currentVhost: {
        ServerNames:[],
        Port:"",
      },
      TitleEditModal:"",
      MemoryLimit:"",
      PhpVersion:"",
      isSftpgoEnabled: false,
      isHttpToHttpsEnabled:false,
      isLetsEncryptEnabled:false,
      isIndexesEnabled:false,
      isAllowUrlfOpenEnabled:false,
      ServerNames:"",
      MaxExecutionTime:"",
      MaxFileUploads:"",
      PostMaxSize:"",
      UploadMaxFilesize:"",
      virtualhost: [],
      NextFpmPort:"",
      hostname: "",
      urlCheckInterval: null,
      loading: {
        getConfiguration: false,
        SaveVhost: false,
      },
      error: {
        getConfiguration: "",
        SaveVhost: "",
        ServerNames:"",
        sftpgo_enabled: "",
        lets_encrypt: "",
        http2https: "",
        isIndexesEnabled: "",
        PhpVersion: "",
        MemoryLimit: "",
        MaxExecutionTime:"",
        MaxFileUploads:"",
        PostMaxSize:"",
        UploadMaxFilesize:""
      },
      value: {
        getConfiguration: "",
        SaveVhost: "",
        ServerNames:"",
        sftpgo_enabled: "",
        lets_encrypt: "",
        http2https: "",
        isIndexesEnabled: "",
        PhpVersion: "",
        MemoryLimit: "",
        MaxExecutionTime:"",
        MaxFileUploads:"",
        PostMaxSize:"",
        UploadMaxFilesize:""
      },
    };
  },
  computed: {
    ...mapState(["instanceName", "core", "appName"]),
  },
  created() {
    this.getConfiguration();
  },
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      vm.watchQueryData(vm);
      vm.urlCheckInterval = vm.initUrlBindingForApp(vm, vm.q.page);
    });
  },
  beforeRouteLeave(to, from, next) {
    clearInterval(this.urlCheckInterval);
    next();
  },
  methods: {
    initvhost() {
      return {
        PhpVersion:"",
        ServerNames:"",
        MemoryLimit:"128",
        UploadMaxFilesize: "4",
        PostMaxSize: "8",
        MaxExecutionTime:"0",
        MaxFileUploads:"20",
        lets_encrypt: false,
        http2https: false,
        status: "enabled",
        isLoading: false,
        isEdit: false,
        port: this.NextFpmPort,
        HttpToHttps: false,
        sftpgo_enabled: false,
        LetsEncrypt: false,
        AllowUrlfOpen: false,
        Indexes: false
      };
    },
    async getConfiguration() {
      this.isShownDeleteVhostModal = false;
      this.loading.getConfiguration = true;
      this.error.getConfiguration = "";
      const taskAction = "get-configuration";

      // register to task error
      this.core.$root.$off(taskAction + "-aborted");
      this.core.$root.$once(
        taskAction + "-aborted",
        this.getConfigurationAborted
      );

      // register to task completion
      this.core.$root.$off(taskAction + "-completed");
      this.core.$root.$once(
        taskAction + "-completed",
        this.getConfigurationCompleted
      );

      const res = await to(
        this.createModuleTaskForApp(this.instanceName, {
          action: taskAction,
          extra: {
            title: this.$t("action." + taskAction),
            isNotificationHidden: true,
          },
        })
      );
      const err = res[0];

      if (err) {
        console.error(`error creating task ${taskAction}`, err);
        this.error.getConfiguration = this.getErrorMessage(err);
        this.loading.getConfiguration = false;
        return;
      }
    },
    getConfigurationAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.getConfiguration = this.core.$t("error.generic_error");
      this.loading.getConfiguration = false;
    },
    getConfigurationCompleted(taskContext, taskResult) {
      const config = taskResult.output;
      if (config.virtualhost.length) {
        config.virtualhost.sort(this.sortByProperty("name"));
      }
      this.virtualhost = config.virtualhost;
      this.NextFpmPort = config.NextFpmPort;
      this.sftp_tcp_port = config.sftp_tcp_port;
      this.sftpgo_service = config.sftpgo_service;
      this.path = config.path
      this.hostname = config.hostname
      this.loading.getConfiguration = false;
    },

    hideDeleteVhostModal() {
      this.isShownDeleteVhostModal = false;
    },

    showDeleteVhostModal(vhost) {
      this.isShownDeleteVhostModal = true;
      this.currentVhost = vhost;
    },

    deleteDomain(vhost) {
      this.removeVhost(vhost);
    },
    async removeVhost(vhost) {
      this.error.removeVhost = "";
      const taskAction = "destroy-vhost";
      // register to task completion
      this.$root.$once(
        taskAction + "-completed",
        this.removeVhostCompleted()
      );
      const res = await to(
        this.createModuleTaskForApp(this.instanceName, {
          action: taskAction,
          data: {
            port: parseInt(vhost.name),
            ServerNames: vhost.ServerNames
          },
          extra: {
            title: this.$t("action." + taskAction),
            description: this.$t("common.processing"),
          },
        })
      );

      const err = res[0];
      if (err) {
        console.error(`error creating task ${taskAction}`, err);
        this.error.removeVhost = this.getErrorMessage(err);
        return;
      }
        this.isShownDeleteVhostModal = false;

    },
    removeVhostCompleted() {
      this.getConfiguration();
    },

    DisableVhost(vhost) {
      this.ServerNames = vhost.ServerNames.join('\n');
      this.isSftpgoEnabled= vhost.sftpgo_enabled;
      this.isHttpToHttpsEnabled= vhost.http2https;
      this.isAllowUrlfOpenEnabled= (vhost.allowurlfopen === "enabled") ? true : false;
      this.isIndexesEnabled= (vhost.Indexes === "enabled") ? true : false;
      this.isLetsEncryptEnabled= vhost.lets_encrypt;
      this.PhpVersion = vhost.PhpVersion;
      this.Port = vhost.Port.toString();
      this.MemoryLimit = vhost.MemoryLimit.toString();
      this.UploadMaxFilesize = vhost.UploadMaxFilesize.toString();
      this.PostMaxSize = vhost.PostMaxSize.toString();
      this.MaxExecutionTime = vhost.MaxExecutionTime.toString();
      this.MaxFileUploads = vhost.MaxFileUploads.toString();
      this.status = (vhost.status === "enabled") ? "disabled": "enabled";
      this.isEdit = true;
      this.isDisable = true;
      this.SaveVhost();
    },
    showEditVhostModal(vhost) {
      // set error to false
      Object.keys(this.error).forEach(key => {
        this.error[key] = false;
      });
      this.TitleEditModal = vhost.ServerNames[0];
      this.ServerNames = vhost.ServerNames.join('\n');
      this.isSftpgoEnabled= vhost.sftpgo_enabled;
      this.isHttpToHttpsEnabled= vhost.http2https;
      this.isAllowUrlfOpenEnabled= (vhost.allowurlfopen === "enabled") ? true : false;
      this.isIndexesEnabled= (vhost.Indexes === "enabled") ? true : false;
      this.isLetsEncryptEnabled= vhost.lets_encrypt;
      this.PhpVersion = vhost.PhpVersion;
      this.Port = vhost.Port.toString();
      this.MemoryLimit = vhost.MemoryLimit.toString();
      this.UploadMaxFilesize = vhost.UploadMaxFilesize.toString();
      this.PostMaxSize = vhost.PostMaxSize.toString();
      this.MaxExecutionTime = vhost.MaxExecutionTime.toString();
      this.MaxFileUploads = vhost.MaxFileUploads.toString();
      this.status = vhost.status;
      this.isEdit = true;
      this.isDisable = false;
      this.isLoading = true;

      this.$nextTick(() => {
        this.isShownCreateVhostModal = true;
      });
},
    showCreateVhostModal() {
      // set error to false
      Object.keys(this.error).forEach(key => {
        this.error[key] = false;
      });
      this.currentVhost = this.initvhost();
      this.ServerNames = this.currentVhost.ServerNames;
      this.isSftpgoEnabled= this.currentVhost.sftpgo_enabled;
      this.isHttpToHttpsEnabled= this.currentVhost.HttpToHttps;
      this.isAllowUrlfOpenEnabled= this.currentVhost.AllowUrlfOpen;
      this.isIndexesEnabled= this.currentVhost.Indexes;
      this.isLetsEncryptEnabled= this.currentVhost.LetsEncrypt;
      this.PhpVersion = this.currentVhost.PhpVersion;
      this.Port = this.currentVhost.port;
      this.MemoryLimit = this.currentVhost.MemoryLimit;
      this.UploadMaxFilesize = this.currentVhost.UploadMaxFilesize;
      this.PostMaxSize = this.currentVhost.PostMaxSize;
      this.MaxExecutionTime = this.currentVhost.MaxExecutionTime;
      this.MaxFileUploads = this.currentVhost.MaxFileUploads;

      this.status = this.currentVhost.status;
      this.isEdit = false;
      this.isDisable = false;
      this.$nextTick(() => {
        this.isShownCreateVhostModal = true;
      });
    },
    hideEditRepoModal() {
        this.loading.SaveVhost = false;
        this.isShownCreateVhostModal = false;
         this.currentVhost = this.initvhost();
    },
    validateConfigureModule() {
      let isValidationOk = true;
      if (!this.ServerNames) {
        this.error.ServerNames = "common.required";
        if (isValidationOk) {
          this.focusElement("ServerNames");
        }
        isValidationOk = false;
      }
      return isValidationOk;
    },
    configureModuleValidationFailed(validationErrors) {
      this.loading.SaveVhost = false;
      let focusAlreadySet = false;

      for (const validationError of validationErrors) {
        const param = validationError.parameter;
        // set i18n error message
        this.error[param] = "virtualhosts." + validationError.error;
        this.value[param] = validationError.value;

        if (!focusAlreadySet) {
          this.focusElement(param);
          focusAlreadySet = true;
        }
      }
    },
    async SaveVhost() {
      const isValidationOk = this.validateConfigureModule();
      if (!isValidationOk) {
        return;
      }

      this.loading.SaveVhost = true;
      
      const taskAction = (!this.isEdit) ? "create-vhost":"update-vhost";

      // register to task error
      this.core.$root.$off(taskAction + "-aborted");
      this.core.$root.$once(
        taskAction + "-aborted",
        this.configureModuleAborted
      );

      // register to task validation
      this.core.$root.$off(taskAction + "-validation-failed");
      this.core.$root.$once(
        taskAction + "-validation-failed",
        this.configureModuleValidationFailed
      );

      // register to task completion
      this.core.$root.$off(taskAction + "-completed");
      this.core.$root.$once(
        taskAction + "-completed",
        this.configureModuleCompleted
      );

      const res = await to(
        this.createModuleTaskForApp(this.instanceName, {
          action: taskAction,
          data: {
            ...(this.isEdit) && {Port: this.Port},
            ServerNames: this.ServerNames.split('\n'),
            sftpgo_enabled: this.isSftpgoEnabled ? true : false,
            lets_encrypt: this.isLetsEncryptEnabled ? true : false,
            http2https: this.isHttpToHttpsEnabled ? true: false,
            Indexes: this.isIndexesEnabled ? "enabled" : "disabled",
            AllowUrlfOpen: this.isAllowUrlfOpenEnabled ? "enabled" : "disabled",
            PhpVersion: this.PhpVersion,
            MemoryLimit: parseInt(this.MemoryLimit),
            UploadMaxFilesize: parseInt(this.UploadMaxFilesize),
            PostMaxSize: parseInt(this.PostMaxSize),
            MaxExecutionTime: parseInt(this.MaxExecutionTime),
            MaxFileUploads: parseInt(this.MaxFileUploads),
            status: this.status
          },
          extra: {
            title: this.isDisable ? this.$t("virtualhosts.Disable_virtual_Host" , {
              instance: this.instanceName,
            }) : this.$t("virtualhosts.instance_configuration", {
              instance: this.instanceName,
            }),
            description: this.$t("virtualhosts.configuring"),
          },
        })
      );
      const err = res[0];

      if (err) {
        console.error(`error creating task ${taskAction}`, err);
        this.error.SaveVhost = this.getErrorMessage(err);
        this.loading.SaveVhost = false;
        return;
      }
    },
    configureModuleAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.SaveVhost = this.core.$t("error.generic_error");
      this.loading.SaveVhost = false;
    },
    configureModuleCompleted() {
        this.loading.SaveVhost = false;
        this.isShownCreateVhostModal = false;
        // reload configuration
        this.getConfiguration();
    },
  },
};
</script>

<style scoped lang="scss">
@import "../styles/carbon-utils";
.mg-bottom {
  margin-bottom: $spacing-04;
}
.mg-left {
  margin-left: $spacing-06;
}
.tooltip-mg-left {
  margin-left: $spacing-02;
}
.empty-state-button {
  margin-top: $spacing-07;
  margin-bottom: $spacing-07;
}
.card-rows {
  display: flex;
  flex-direction: column;
}
.card-row {
  margin-bottom: $spacing-05;
  display: flex;
  justify-content: center;
}
.card-row:last-child {
  margin-bottom: 0;
}
</style>
