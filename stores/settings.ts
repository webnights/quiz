import { defineStore } from 'pinia'
import type { QuestionType } from './questions'

export const useMySettingsStore = defineStore('mySettingsStore', () =>{
  const question_types = reactive<{ [key in QuestionType]: boolean }>({
      "text": true,
      "select": true,
      "multiple-select": true,
      "order": true,
      "category": true
  })
  const repeat = ref<boolean>(false)
  let questions_bin = ref<boolean[]>([])

  return {question_types, repeat, questions_bin}
}, {persist: true})

